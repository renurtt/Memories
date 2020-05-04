//
//  FirstViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 22.04.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import Parse
import UIKit

struct CellData {
    let header : String
    let date : Date
    let memoryContent : String
    let id : String
}
class MemoriesViewController: UITableViewController {
    var data = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.register(CustomCellTableViewCell.self, forCellReuseIdentifier: "memoryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        let topButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        if let image  = UIImage(systemName: "plus") {
            topButton.setImage(image, for: [])
        }
        
        topButton.sizeToFit()
        self.tableView.tableHeaderView = topButton
        //self.tableView.tableHeaderView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        self.tableView.tableHeaderView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.tableHeaderView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.tableHeaderView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        getMemories()
    }
    
    func getMemories() {
        let query = PFQuery(className: "Memories")
        query.whereKey("owner", equalTo: PFUser.current()!)
        query.order(byDescending: "date")
        
        query.cachePolicy = PFCachePolicy.networkElseCache
        
        let spinner = UIViewController.displaySpinner(onView: self.tableView, darkenBack: false)
        
        
        query.findObjectsInBackground {
            (objects, error) in
            if let error = error {
                print("Error: \(error) \(error.localizedDescription)")
                return
            }
            if let objects = objects {
                for object in objects {
                    self.data.append(CellData.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!))
                }
                UIViewController.removeSpinner(spinner: spinner)
                self.tableView.reloadSections(IndexSet(integer: 0), with: .bottom)
                /*
                 UIView.transition(with: self.tableView,
                 duration: 0.35,
                 options: .transitionFlipFromLeft,
                 animations: { self.tableView.reloadData() })*/
                
                
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let currentUser = PFUser.current()
        if currentUser == nil {
            loadSignUpScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func loadSignUpScreen(){
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "memoryCell") as! CustomCellTableViewCell
        cell.header = data[indexPath.row].header
        cell.date = data[indexPath.row].date
        cell.layoutSubviews()
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}

