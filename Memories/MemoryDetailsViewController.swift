//
//  MemoryDetails.swift
//  Memories
//
//  Created by Renat Nurtdinov on 05.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit
import Parse

class MemoryDetailsViewController: UIViewController, UITextViewDelegate {
    @IBOutlet fileprivate var header : UITextView!
    var content : UITextView!
    var mentions : UIButton!
    @IBOutlet weak var date: UIButton!
    let datePicker = UIDatePicker()
    let txtView = UITextView()
    var toolbar : UIToolbar!
    let formatter = DateFormatter()
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        var text = "Memory dated " + formatter.string(from: memory.date) + ":\n\n"
        text += memory.header + "\n\n"
        text += memory.memoryContent
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
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
    
    @objc func doneEditing(){
        self.view.endEditing(true)
    }
    
    var memory : Memory!
    var memoryNumber : Int!
    var memoriesVC : MemoriesViewController?
    var memoriesShareVC : ShareViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.sizeToFit()
        date.sizeToFit()
        // Do any additional setup after loading the view.
        content = UITextView()
        mentions = UIButton()
        self.view.addSubview(mentions)
        content.translatesAutoresizingMaskIntoConstraints = false
        content.font = UIFont(name: "Arial", size: 20.0)
        content.textAlignment = NSTextAlignment.justified
        content.backgroundColor = UIColor(named: "Default")
        self.view.addSubview(content)
        content.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        content.text = memory.memoryContent
        
        header.text = memory.header
        
        formatter.dateFormat = "dd/MM/yyyy"
        date.setTitle(formatter.string(from: memory.date), for: .normal)
        
        self.view.addSubview(txtView)
        datePicker.datePickerMode = .date
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        datePicker.setDate(self.memory.date, animated: true)
        datePicker.addTarget(self, action: #selector(MemoryDetailsViewController.datePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditing));
        doneButton.tintColor = UIColor.red
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([doneButton,spaceButton], animated: false)
        
        header.delegate = self
        
        mentions.setTitle(getMentionsString(), for: .normal)
        
        mentions.setTitleColor(UIColor.init(red: 255/256, green: 120/256, blue: 62/256, alpha: 1.0), for: .normal)
        mentions.translatesAutoresizingMaskIntoConstraints = false
        
        mentions.sizeToFit()
        mentions.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 5).isActive = true
        mentions.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -5).isActive = true
        mentions.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        content.bottomAnchor.constraint(equalTo: mentions.topAnchor, constant: -20).isActive = true
        
        mentions.heightAnchor.constraint(equalToConstant: 10).isActive = true
        mentions.addTarget(self, action: #selector(MemoryDetailsViewController.mentionsPressed(_:)), for: UIControl.Event.touchUpInside)
        mentions.contentHorizontalAlignment = .left
        
        if (memoriesShareVC != nil) {
            header.isEditable = false
            content.isEditable = false
            date.isEnabled = false
            self.view.backgroundColor = UIColor(red: 240/244, green: 1, blue: 245/255, alpha: 1)
        }
        else {
            txtView.inputAccessoryView = toolbar
            header.inputAccessoryView = toolbar
            content.inputAccessoryView = toolbar
        }
    }
    
    @IBAction func mentionsPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MentionsViewController") as? MentionsViewController {
            vc.memory = self.memory
            vc.memoryDetailsVC = self
            vc.editable = (memoriesShareVC == nil)
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true, completion: nil)
        }
    }
    
    func getMentionsString() -> String {
        var mentionsString = ""
        var second = true
        if  memory.mentions.count != 1 {
            let mentions = memory.mentions
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
            mentionsString += "no mentions"
        }
        return mentionsString
    }
    
    @objc func keyboardWillShown(notification: NSNotification) {
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let selectedIndexPath = self.memoriesVC?.tableView.indexPathForSelectedRow {
            self.memoriesVC?.tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
        
        if let selectedIndexPath = self.memoriesShareVC?.tableView.indexPathForSelectedRow {
            self.memoriesShareVC?.tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
        
        let new_mem = Memory(header: self.header.text, date: formatter.date(from: self.date.title(for: .normal)!)!, memoryContent: self.content.text, id: memory.id)
        new_mem.mentions = memory.mentions
        
        if new_mem.header.isEmpty || new_mem.memoryContent.isEmpty {
            return
        }
        
        memory = new_mem
        self.memoriesVC?.updateData(at: memoryNumber, new_data: new_mem)
        self.memoriesShareVC?.tableView.reloadRows(at: [IndexPath(row: memoryNumber, section: 0)], with: .fade)
        
        let query = PFQuery(className:"Memories")
        
        query.getObjectInBackground(withId: memory.id) {
            (new_memory: PFObject?, error: Error?) -> Void in
            if let error = error {
                print(error)
            } else if let new_memory = new_memory {
                new_memory["header"] = new_mem.header
                new_memory["memoryContent"] = new_mem.memoryContent
                new_memory["date"] = new_mem.date
                new_memory["mentions"] = new_mem.mentions
                new_memory.saveInBackground()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            header.resignFirstResponder()
            return false
        }
        return true
    }
}
