//
//  MemoryForShareTableViewCell.swift
//  Memories
//
//  Created by Renat Nurtdinov on 08.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit
import Parse

class MemoryForShareTableViewCell: UITableViewCell{
    
    var header : String?
    var date : String?
    var content : String?
    var owner : String?
    
    var headerView : UITextView = {
        var headerView = UITextView()
        headerView.font = UIFont.init(name: "EuphemiaUCAS", size: 30)
        headerView.isScrollEnabled = false
        headerView.backgroundColor = nil
        headerView.textColor = UIColor.init(red: 55/256, green: 0/256, blue: 66/256, alpha: 1.0)
        headerView.isEditable = false
        headerView.isSelectable = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.textAlignment = NSTextAlignment.justified
        
        headerView.isUserInteractionEnabled = false
        
        return headerView
    }()
    
    var dateView : UITextView = {
        var dateView = UITextView()
        dateView.textAlignment = NSTextAlignment.right
        
        dateView.isEditable = false
        dateView.isSelectable = false
        dateView.textColor = UIColor.init(red: 162/255, green: 150/255, blue: 105/255, alpha: 1.0)
        dateView.font = UIFont.init(name: "Courier", size: 17)
        dateView.isScrollEnabled = false
        dateView.backgroundColor = nil
        
        dateView.translatesAutoresizingMaskIntoConstraints = false
        
        dateView.isUserInteractionEnabled = false
        
        return dateView
    }()
    
    var ownerView : UITextView = {
        var dateView = UITextView()
        dateView.textAlignment = NSTextAlignment.left
        
        dateView.isEditable = false
        dateView.isSelectable = false
        dateView.textColor = UIColor.init(red: 162/255, green: 150/255, blue: 105/255, alpha: 1.0)
        dateView.font = UIFont.init(name: "Courier", size: 17)
        dateView.isScrollEnabled = false
        dateView.backgroundColor = nil
        
        dateView.translatesAutoresizingMaskIntoConstraints = false
        
        dateView.isUserInteractionEnabled = false
        
        return dateView
    }()
    
    
    var memoryContentView : UITextView = {
        var memoryContentView = UITextView()
        memoryContentView.textAlignment = NSTextAlignment.justified
        
        memoryContentView.isEditable = false
        memoryContentView.isSelectable = false
        memoryContentView.textColor = UIColor.init(red: 55/256, green: 0/256, blue: 66/256, alpha: 1.0)
        memoryContentView.font = UIFont.init(name: "Arial", size: 15)
        memoryContentView.isScrollEnabled = false
        memoryContentView.backgroundColor = nil
        
        memoryContentView.translatesAutoresizingMaskIntoConstraints = false
        
        memoryContentView.isUserInteractionEnabled = false
        
        return memoryContentView
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(headerView)
        self.addSubview(dateView)
        self.addSubview(memoryContentView)
        self.addSubview(ownerView)
        
        self.backgroundColor = UIColor.init(red: 256/256, green: 256/256, blue: 256/256, alpha: 0.0)
        
        dateView.rightAnchor.constraint(greaterThanOrEqualTo: self.rightAnchor, constant: -20).isActive = true
        dateView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        dateView.sizeToFit()
        
        ownerView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 20).isActive = true
        ownerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        ownerView.sizeToFit()
        
        headerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        //headerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        
        memoryContentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        memoryContentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        memoryContentView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -5).isActive = true
        memoryContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -10).isActive = true
        
        
        
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 3.0
        self.contentView.layer.borderColor = UIColor.init(red: 253/255, green: 230/255, blue: 126/255, alpha: 1).cgColor
        self.contentView.layer.masksToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        
        let bgColorView = UIView(frame: self.contentView.layer.frame)
        bgColorView.layer.cornerRadius = 10.0
        bgColorView.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 220/255, alpha: 1)
        self.selectedBackgroundView = bgColorView
        
        if let header = header {
            headerView.text = header
        }
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            // again convert your date to string
            let myString = date
            dateView.text = myString
        }
        if let content = content {
            if content.count > 250 {
                let index = content.index(content.startIndex, offsetBy: 150)
                let substring = content.prefix(upTo: index)
                memoryContentView.text = String(substring)  + "..."
            }
            else {
                memoryContentView.text = content
            }
        }
        if let owner = owner {
            self.ownerView.text = "@" + owner
        }
        
    }
    
}
