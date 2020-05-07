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
    @IBOutlet weak var date: UIButton!
    let datePicker = UIDatePicker()
    let txtView = UITextView()
    var toolbar : UIToolbar!
    let formatter = DateFormatter()
    
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
    var memoriesVC : MemoriesViewController!
    
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
        content.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        header.text = memory.header
        content.text = memory.memoryContent
        
        formatter.dateFormat = "dd/MM/yyyy"
        date.setTitle(formatter.string(from: memory.date), for: .normal)
        
        self.view.addSubview(txtView)
        datePicker.datePickerMode = .date
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        datePicker.setDate(self.memory.date, animated: true)
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
            x.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            content = x
            self.content.isHidden = false
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let selectedIndexPath = self.memoriesVC.tableView.indexPathForSelectedRow {
            self.memoriesVC.tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
        
        let new_mem = Memory(header: self.header.text, date: formatter.date(from: self.date.title(for: .normal)!)!, memoryContent: self.content.text, id: memory.id)
        
        if new_mem.header.isEmpty || new_mem.memoryContent.isEmpty {
            return
        }
        
        memory = new_mem
        self.memoriesVC?.updateData(at: memoryNumber, new_data: new_mem)
        
        let query = PFQuery(className:"Memories")
        
        query.getObjectInBackground(withId: memory.id) {
            (new_memory: PFObject?, error: Error?) -> Void in
            if let error = error {
                print(error)
            } else if let new_memory = new_memory {
                new_memory["header"] = new_mem.header
                new_memory["memoryContent"] = new_mem.memoryContent
                new_memory["date"] = new_mem.date
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
