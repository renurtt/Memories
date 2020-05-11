//
//  SecondViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 22.04.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit
import Parse

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    
    @IBOutlet weak var noMemoriesLabel: UILabel!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "memoryShareCell") as! MemoryForShareTableViewCell
        
        cell.header = memories[indexPath.row].header
        let memoryDate = memories[indexPath.row].date
        if memoryDate == date1 {
            cell.date = "year ago"
        }
        else if memoryDate == date3 {
            cell.date = "three years ago"
        }
        else if memoryDate == date5 {
            cell.date = "five years ago"
        }
        else {
            cell.date = "many years ago"
        }
        
        cell.content = memories[indexPath.row].memoryContent
        cell.owner = memories[indexPath.row].mentions[0]
        cell.layoutSubviews()
        return cell
    }
    
    let formatterDdMm : DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    let formatter : DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    let formatterYyyy : DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    @IBOutlet fileprivate var username: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var memories = [Memory]()
    var date1 : Date!
    var date3 : Date!
    var date5 : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.backgroundColor = UIColor.init(named: "Default")
        self.tableView.register(MemoryForShareTableViewCell.self, forCellReuseIdentifier: "memoryShareCell")
        username.text = ""
        if let username1 = PFUser.current()?.username {
            username.text = "@" + username1
        }
        else {
            logoutButton.setTitle("Sign in", for: .normal)
        }
        
        username.sizeToFit()
        
        let day = formatterDdMm.string(from: Date(timeIntervalSinceNow: 0))
        let year = Int(formatterYyyy.string(from: Date(timeIntervalSinceNow: 0))) ?? 0
        var string = day + "/" + String(year - 1)
        date1 = formatter.date(from: string)
        string = day + "/" + String(year - 3)
        date3 = formatter.date(from: string)
        string = day + "/" + String(year - 5)
        date5 = formatter.date(from: string)
        tableView.delegate = self
        tableView.dataSource = self
        
        //noMemoriesTextView.translatesAutoresizingMaskIntoConstraints = false
        //noMemoriesTextView.centerYAnchor.constraint(view.centerYAnchor).isActive.true
        //noMemoriesTextView.centerXAnchor.constraint(view.centerXAnchor)
    }
    
    
    func updateMemories() {
        if (PFUser.current() == nil) {
            self.noMemoriesLabel.text = "No memories for today.\nCome back later!"
            self.noMemoriesLabel.isHidden = false
            return
        }
        let query = PFQuery(className: "Memories")
        query.whereKey("owner", equalTo: PFUser.current()!)
        query.whereKey("date", containedIn: [date1!, date3!, date5!])
        query.order(byAscending: "date")
        
        let query2 = PFQuery(className: "Memories")
        query2.whereKey("mentions", contains: PFUser.current()?.username)
        query2.whereKey("owner", notEqualTo: PFUser.current()!)
        query2.whereKey("date", containedIn: [date1!, date3!, date5!])
        query2.order(byAscending: "date")
        
        let vc = UIViewController.displaySpinner(onView: self.view, darkenBack: false)
        self.memories = [Memory]()
        query.findObjectsInBackground {
            (objects, error) in
            if let error = error {
                print("Error: \(error) \(error.localizedDescription)")
                //self.refreshControl?.endRefreshing()
                return
            }
            if let objects = objects {
                for object in objects {
                    let new_obj = Memory.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!)
                    if let mentions = object.object(forKey: "mentions") {
                        new_obj.mentions = mentions as! [String]
                    }
                    self.memories.append(new_obj)
                }
            }
            
            query2.findObjectsInBackground {
                (objects1, error) in
                if let error = error {
                    print("Error: \(error) \(error.localizedDescription)")
                    self.tableView.reloadData()
                    UIViewController.removeSpinner(spinner: vc)
                    return
                }
                if let objects1 = objects1 {
                    for object in objects1 {
                        let new_obj = Memory.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!)
                        if let mentions = object.object(forKey: "mentions") {
                            new_obj.mentions = mentions as! [String]
                        }
                        self.memories.append(new_obj)
                    }
                    UIViewController.removeSpinner(spinner: vc)
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }
                if (self.memories.count == 0) {
                    self.noMemoriesLabel.text = "No memories for today."
                    self.noMemoriesLabel.isHidden = false
                }
                else {
                    self.noMemoriesLabel.isHidden = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateMemories()
    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    func loadLoginScreen(){
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutOfApp(_ sender: UIButton) {
        if (PFUser.current() == nil) {
            loadLoginScreen()
            return
        }
        let sv = UIViewController.displaySpinner(onView: self.view, darkenBack: true)
        PFUser.logOutInBackground { (error: Error?) in
            UIViewController.removeSpinner(spinner: sv)
            if (error == nil){
                self.loadLoginScreen()
            }else{
                if let descrip = error?.localizedDescription{
                    self.displayErrorMessage(message: descrip)
                }else{
                    self.displayErrorMessage(message: "error logging out")
                }
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MemoryDetailsViewController") as? MemoryDetailsViewController {
            
            vc.memoryNumber = indexPath.row
            vc.memory = memories[indexPath.row]
            
            vc.memoriesShareVC = self
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true, completion: nil)
        }
    }
}
