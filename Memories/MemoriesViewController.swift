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
    
    func equalTo(rhs: CellData) -> Bool {
        return self.id == rhs.id && self.header == rhs.header && self.date == rhs.date && self.memoryContent == rhs.memoryContent
    }
}

func ==(lhs: CellData, rhs: CellData) -> Bool {
    return lhs.equalTo(rhs: rhs)
}

class MemoriesViewController: UITableViewController {
    var data = [CellData]() {
        didSet {
            self.dataChanged = true
        }
    }
    var dataChanged = false
    
    var currentUser : PFUser?
    
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
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(MemoriesViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        self.refreshControl?.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 50).isActive = true
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
                self.data.append(CellData.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!))
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            
            self.dataChanged = false
        }
        
        query.cachePolicy = PFCachePolicy.networkOnly
        query.findObjectsInBackground {
            (objects, error) in
            if let error = error {
                print("Error: \(error) \(error.localizedDescription)")
                return
            }
            if let objects = objects {
                if (objects.count>0) {
                    var new_obj :CellData
                    var object :PFObject
                    
                    for i in 0...objects.count-1 {
                        object = objects[i]
                        new_obj = CellData.init(header: object.object(forKey: "header") as! String, date: object.object(forKey: "date") as! Date, memoryContent: object.object(forKey: "memoryContent") as! String, id: object.objectId!)
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
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
                        self.dataChanged = false
                    }
                }
            }
            self.refreshControl?.endRefreshing()
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if currentUser == nil {
            loadSignInScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentUser != nil {
            getMemories()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        getMemories()
    }
}

