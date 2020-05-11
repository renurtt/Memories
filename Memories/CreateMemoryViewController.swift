//
//  CreateMemoryViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 06.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit
import Parse

class CreateMemoryViewController: UIViewController, UITextViewDelegate {
    @IBOutlet fileprivate var header : UITextView!
    var content : UITextView!
    @IBOutlet weak var date: UIButton!
    let datePicker = UIDatePicker()
    let txtView = UITextView()
    var toolbar : UIToolbar!
    let formatter = DateFormatter()
    
    var Saved : Bool = false
    var mentions : UIButton = UIButton()
    
    var mentionsArray : [String] = [PFUser.current()!.username!]
    
    var memoriesVC : MemoriesViewController!
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        date.setTitle(formatter.string(from: datePicker.date), for: .normal)
    }
    
    @IBAction func datePressed(_ sender: Any) {
        if txtView.isFirstResponder {
            txtView.resignFirstResponder()
            return
        }
        self.datePicker.setDate(formatter.date(from: date.title(for: .normal)!)!, animated: true)
        
        //ToolBar
        txtView.inputView = datePicker
        txtView.becomeFirstResponder()
    }
    @IBAction func CancelButtonPressed(_ sender: Any) {
        Saved = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SaveButtonPressed(_ sender: Any) {
        saveData()
        
    }
    
    func saveData() {
        let new_mem = Memory(header: self.header.text, date: formatter.date(from: self.date.title(for: .normal)!)!, memoryContent: self.content.text, id: "")
        new_mem.mentions = mentionsArray
        
        if new_mem.header.isEmpty || new_mem.memoryContent.isEmpty {
            displayErrorMessage(message: "Memory title and content can't be empty.")
            return
        }
        //
        
        //
        self.memoriesVC.addData(new_data: new_mem)
        Saved = true
        
        let new_memory = PFObject(className:"Memories")
        new_memory["header"] = new_mem.header
        new_memory["memoryContent"] = new_mem.memoryContent
        new_memory["date"] = new_mem.date
        new_memory["owner"] = PFUser.current()
        
        new_memory["mentions"] = new_mem.mentions
        
        new_memory.saveInBackground {
            (success: Bool, error: Error?) in
            if let error = error {
                print(error)
            } else {
                new_mem.id = new_memory.objectId!
            }
        }
        if (!self.isBeingDismissed) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (!Saved && (header.text != "Header" || content.text != "Content")) {
            saveData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.sizeToFit()
        date.sizeToFit()
        // Do any additional setup after loading the view.
        content = UITextView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.font = UIFont(name: "Arial", size: 20.0)
        content.textAlignment = NSTextAlignment.justified
        content.backgroundColor = UIColor(named: "Default")
        self.view.addSubview(content)
        self.view.addSubview(mentions)
        content.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: mentions.topAnchor, constant: -20).isActive = true
        
        header.text = "Header"
        content.text = "Content"
        header.selectAll(nil)
        content.selectAll(nil)
        
        formatter.dateFormat = "dd/MM/yyyy"
        date.setTitle(formatter.string(from: Date()), for: .normal)
        
        self.view.addSubview(txtView)
        datePicker.datePickerMode = .date
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        datePicker.setDate(Date(), animated: true)
        datePicker.addTarget(self, action: #selector(MemoryDetailsViewController.datePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditing));
        doneButton.tintColor = UIColor.red
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([doneButton,spaceButton], animated: false)
        txtView.inputAccessoryView = toolbar
        header.inputAccessoryView = toolbar
        content.inputAccessoryView = toolbar
        
        header.delegate = self
        
        
        //mentions
        mentions.setTitle(getMentionsString(), for: .normal)
        
        mentions.setTitleColor(UIColor.init(red: 20/256, green: 126/256, blue: 251/256, alpha: 1.0), for: .normal)
        mentions.translatesAutoresizingMaskIntoConstraints = false
        
        mentions.sizeToFit()
        mentions.leftAnchor.constraint(equalTo: self.header.leftAnchor, constant: 5).isActive = true
        mentions.rightAnchor.constraint(equalTo: self.header.rightAnchor, constant: -5).isActive = true
        mentions.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        mentions.heightAnchor.constraint(equalToConstant: 10).isActive = true
        mentions.addTarget(self, action: #selector(MemoryDetailsViewController.mentionsPressed(_:)), for: UIControl.Event.touchUpInside)
        mentions.contentHorizontalAlignment = .left
    }
    
    @IBAction func mentionsPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MentionsViewController") as? MentionsViewController {
            vc.memory = Memory(header: "", date: Date(), memoryContent: "", id: "")
            vc.memory.mentions = mentionsArray
            
            vc.memoryCreateVC = self
            
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true, completion: nil)
        }
    }
    
    func getMentionsString() -> String {
        var mentionsString = ""
        var second = true
        if  mentionsArray.count != 1 {
            let mentions = mentionsArray
            var first = true
            for mention in mentions {
                if first {
                    first = false
                    continue
                }
                if mentionsString.count + mention.count + 3 < 35 {
                    if (second) {
                        second = false
                    }
                    else {
                        mentionsString += ", "
                    }
                    mentionsString += "@" + mention
                }
                else {
                    mentionsString += "..."
                    break
                }
            }
        }
        else {
            mentionsString += "Add mentions"
        }
        return mentionsString
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        if (self.content.isFirstResponder) {
            let info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                //self.view.frame.origin.y = -keyboardFrame.height
                self.content.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardFrame.height).isActive = true
            })
        }
        else if (self.mentions.isFirstResponder) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? UITabBarController {
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .coverVertical
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHidden(notification: NSNotification) {
        if (self.content.isFirstResponder) {
            let x = UITextView()
            x.translatesAutoresizingMaskIntoConstraints = false
            x.font = UIFont(name: "Arial", size: 20.0)
            x.textAlignment = NSTextAlignment.justified
            x.backgroundColor = UIColor(named: "Default")
            x.inputAccessoryView = toolbar
            x.setContentOffset(content.contentOffset, animated: false)
            
            x.text = content.text
            
            x.isHidden = true
            self.content.removeFromSuperview()
            self.view.addSubview(x)
            
            x.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
            x.leftAnchor.constraint(equalTo: self.header.leftAnchor).isActive = true
            x.rightAnchor.constraint(equalTo: self.header.rightAnchor).isActive = true
            x.bottomAnchor.constraint(equalTo: mentions.topAnchor, constant: -10).isActive = true
            content = x
            self.content.isHidden = false
        }
    }
    
    @objc func doneEditing(){
        self.view.endEditing(true)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            header.resignFirstResponder()
            if (content.text.isEmpty || content.text == "Content") {
                content.becomeFirstResponder()
                content.selectAll(nil)
            }
            return false
        }
        return true
    }
}
