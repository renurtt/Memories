//
//  CustomCellTableViewCell.swift
//  Memories
//
//  Created by Renat Nurtdinov on 03.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit

class MemoryForDiaryTableViewCell: UITableViewCell {
    
    var header : String?
    var date : Date?
    
    var headerView : UITextView = {
        var headerView = UITextView()
        headerView.font = UIFont.init(name: "EuphemiaUCAS", size: 25)
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
        dateView.textColor = UIColor.init(red: 0, green: 80/256, blue: 80/256, alpha: 1.0)
        dateView.font = UIFont.init(name: "Courier", size: 14)
        dateView.isScrollEnabled = false
        dateView.backgroundColor = nil
        
        dateView.translatesAutoresizingMaskIntoConstraints = false
        
        dateView.isUserInteractionEnabled = false
        
        return dateView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(headerView)
        self.addSubview(dateView)
        
        self.backgroundColor = UIColor.init(red: 256/256, green: 256/256, blue: 256/256, alpha: 0.0)
        
        //dateView.leftAnchor.constraint(equalTo: self.headerView.rightAnchor).isActive = true
        dateView.rightAnchor.constraint(greaterThanOrEqualTo: self.rightAnchor, constant: -10).isActive = true
        dateView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        dateView.bottomAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 30).isActive = true
        dateView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        headerView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 10).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        headerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let header = header {
            headerView.text = header
        }
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let myString = formatter.string(from: date)
            dateView.text = myString
        }
    }
    
}
