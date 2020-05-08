//
//  FirstViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 22.04.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import Parse
import UIKit

public class Memory {
    internal init(header: String, date: Date, memoryContent: String, id: String) {
        self.header = header
        self.date = date
        self.memoryContent = memoryContent
        self.id = id
    }
    
    let header : String
    let date : Date
    let memoryContent : String
    var id : String
    
    var mentions : [String] = []
    
    func equalTo(rhs: Memory) -> Bool {
        return self.id == rhs.id && self.header == rhs.header && self.date == rhs.date && self.memoryContent == rhs.memoryContent && self.mentions == rhs.mentions
    }
}

func ==(lhs: Memory, rhs: Memory) -> Bool {
    return lhs.equalTo(rhs: rhs)
}

class MemoriesViewController: UITableViewController {
    var data = [Memory]() {
        didSet {
            self.dataChanged = true
        }
    }
    var dataChanged = false
    
    var currentUser : PFUser?
    
    var imageView :UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        currentUser = PFUser.current()
        
        self.tableView.register(CustomCellTableViewCell.self, forCellReuseIdentifier: "memoryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        self.tableView.backgroundColor = UIColor.init(red: 256/256, green: 256/256, blue: 245/256, alpha: 1.0)
        
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
         /*
         //indicator of connection (not used)
         imageView = UIImageView(image: UIImage(systemName: "cloud.fill"))
         self.tableView.tableHeaderView?.addSubview(imageView!)
         imageView?.leftAnchor.constraint(greaterThanOrEqualTo: self.tableView.leftAnchor, constant: 30).isActive = true
         imageView?.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
         imageView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
         imageView?.isHidden = true
        */
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(MemoriesViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        self.refreshControl?.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 50).isActive = true
        
        topButton.addTarget(self, action: #selector(MemoriesViewController.createButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateMemoryViewController") as? CreateMemoryViewController {
            vc.memoriesVC = self
            
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true, completion: nil)
        }
    }
    
    func getMemories() {
        let query = PFQuery(className: "Memories")
        query.whereKey("owner", equalTo: PFUser.current()!)
        query.order(byDescending: "date")
        
        //if this is our first time loading data after launching app, then we first try to get data from cache
        //data CLEARS after app closure, but KEEPS after view controller closure and might be (and will be) accessed again during current session
        //so we dont use from-cache loading if it has been already done during this "session" (time after app open) to avoid doubling data and accomplish it only once during one session
        
        //cache clears after logout that's why we always see animated from-network loading after log in
        if (data.isEmpty) {
            query.cachePolicy = PFCachePolicy.cacheOnly
            
            var objects = [PFObject]()
            do {
                objects = try query.findObjects()
            }
            catch {
                print(error)
            }
            for object in objects {
                let new_obj = Memory.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!)
                if let mentions = object.object(forKey: "mentions") {
                    new_obj.mentions = mentions as! [String]
                }
                self.data.append(new_obj)
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            
            
        }
        
        self.dataChanged = false
        query.cachePolicy = PFCachePolicy.networkOnly
        
        query.findObjectsInBackground {
            (objects, error) in
            if let error = error {
                print("Error: \(error) \(error.localizedDescription)")
                self.refreshControl?.endRefreshing()
                return
            }
            if let objects = objects {
                if (objects.count>0) {
                    var new_obj :Memory
                    var object :PFObject
                    
                    for i in 0...objects.count-1 {
                        object = objects[i]
                        new_obj = Memory.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!)
                        if let mentions = object.object(forKey: "mentions") {
                            new_obj.mentions = (mentions as! [String])
                        }
                        if i < self.data.count && !(new_obj == self.data[i]) || i >= self.data.count {
                            if i < self.data.count {
                                self.data[i] = new_obj
                            }
                            else {
                                self.data.append(new_obj)
                            }
                        }
                    }
                    while (objects.count < self.data.count) {
                        self.data.removeLast()
                    }
                    if (self.dataChanged) {
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                        self.dataChanged = false
                    }
                }
            }
            self.refreshControl?.endRefreshing()
        }
    }

    func updateData(at i : Int, new_data : Memory) {
        data[i] = new_data
        self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
    }
    
    func addData(new_data : Memory) {
        data.insert(new_data, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentUser == nil {
            loadSignInScreen()
        }
        self.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentUser != nil {
            getMemories()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let query = PFQuery(className: "Memories")
            
            query.whereKey("objectId", equalTo: data[indexPath.row].id)
            query.findObjectsInBackground { (objects :Optional<Array<PFObject>> , error: Optional<Error>) -> () in
                if let objects = objects {
                    for object in objects {
                        object.deleteEventually()
                    }
                }
            }
            
            data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func loadSignInScreen(){
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MemoryDetailsViewController") as? MemoryDetailsViewController {
            
            vc.memoryNumber = indexPath.row
            vc.memory = data[indexPath.row]
            vc.memoriesVC = self
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getMemories()
    }
}

