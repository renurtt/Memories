//
//  MentionsViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 07.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit
import Parse

class MentionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropDownList: UITableView!
    var memory : Memory!
    var memoryDetailsVC : MemoryDetailsViewController?
    var memoryCreateVC : CreateMemoryViewController?
    var matches = [PFUser]()
    
    let toolbar = UIToolbar()
    
    var editable : Bool = true
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(named: "Default")
        tableView.dataSource = self
        tableView.delegate = self
        
        dropDownList.dataSource = self
        dropDownList.delegate = self
        dropDownList.backgroundColor = UIColor(red: 1, green: 1, blue: 200/256, alpha: 1)
        dropDownList.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        dropDownList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.sizeToFit()
        dropDownList.sizeToFit()
        self.dropDownList.isHidden = true
        dropDownList.isUserInteractionEnabled = true
        
        textField.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditing));
        doneButton.tintColor = UIColor.red
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        self.toolbar.setItems([doneButton,spaceButton], animated: false)
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        if (memory.mentions.count == 1) {
            textField.becomeFirstResponder()
        }
        if (!editable) {
            tableView.isUserInteractionEnabled = false
            textField.isEnabled = false
        }
    }
    
    @objc func keyboardWillShown(notification: NSNotification) {
            let info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                //self.view.frame.origin.y = -keyboardFrame.height
                self.dropDownList.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardFrame.height).isActive = true
            })
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.dropDownList.isHidden = true
        return true
    }
    @objc func doneEditing(){
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let username = matches[indexPath.row].username
        if (username == PFUser.current()!.username) {
            displayErrorMessage(message: "you can not add yourself to mentions (:")
            self.textField.text = ""
            return
        }
        
        if (self.memory.mentions.contains(username!)) {
            displayErrorMessage(message: "you already added this user")
            self.textField.text = ""
            return
        }
        
        UIView.animate(withDuration: 1.0, delay: 1.2, options: .curveEaseOut, animations: {
            self.dropDownList.isHidden = true
        }, completion: nil)
        
        self.memory.mentions.append(username!)
        self.tableView.insertRows(at: [IndexPath(row: self.memory.mentions.count-2, section: 0)], with: .fade)
        self.textField.text = ""
        self.view.endEditing(true)
        self.dropDownList.deselectRow(at: indexPath, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 1.0, delay: 1.2, options: .curveEaseOut, animations: {
            self.dropDownList.isHidden = false
        }, completion: nil)
        let textFieldText = textField.text!
        if (textFieldText == "") {
            self.view.endEditing(true)
        }
        
        if (textFieldText != "") {
            let query = PFUser.query()
            let textFieldText = textFieldText
            
            query?.whereKey("username", contains: textFieldText)
            
            let vc = UIViewController.displaySpinner(onView: self.view, darkenBack: false)
            matches = [PFUser]()
            query?.findObjectsInBackground() {
                (users, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let users = users as? [PFUser]{
                    for user in users {
                        if (!self.matches.contains(user)) {
                            self.matches.append(user)
                        }
                    }
                    UIViewController.removeSpinner(spinner: vc)
                    self.dropDownList.reloadData()
                }
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == self.tableView && editingStyle == .delete) {
            memory.mentions.remove(at: indexPath.row+1)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView) {
            return self.memory.mentions.count - 1
        }
        if (tableView == self.dropDownList) {
            return self.matches.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.backgroundColor = UIColor(named: "Default")
            cell.textLabel?.textColor = UIColor.init(red: 255/256, green: 120/256, blue: 62/256, alpha: 1.0)
            cell.isUserInteractionEnabled = false
            cell.textLabel!.text = "@" + memory.mentions[indexPath.row+1]
            return cell
        }
        if (tableView == self.dropDownList) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.backgroundColor = UIColor(named: "Default")
            cell.textLabel?.textColor = UIColor.init(red: 72/256, green: 129/256, blue: 94/256, alpha: 1.0)
            cell.textLabel!.text = "      " + matches[indexPath.row].username!
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        memoryDetailsVC?.mentions.setTitle(memoryDetailsVC?.getMentionsString(), for: .normal)
        memoryCreateVC?.mentionsArray = memory.mentions
        memoryCreateVC?.mentions.setTitle(memoryCreateVC?.getMentionsString(), for: .normal)
    }

    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
}
