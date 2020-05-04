//
//  CustomCellTableViewCell.swift
//  Memories
//
//  Created by Renat Nurtdinov on 03.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    var header : String?
    var date : Date?
    
    var headerView : UITextView = {
        var headerView = UITextView()
        headerView.font = UIFont.init(name: "EuphemiaUCAS", size: 25)
        headerView.isScrollEnabled = false
        headerView.backgroundColor = nil
        headerView.isEditable = false
        headerView.isSelectable = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        return headerView
    }()
    
    var dateView : UITextView = {
        var dateView = UITextView()
        dateView.textAlignment = NSTextAlignment.right
        
        dateView.isEditable = false
        dateView.isSelectable = false
        dateView.textColor = UIColor.red
        dateView.font = UIFont.init(name: "Courier", size: 14)
        dateView.isScrollEnabled = false
        dateView.backgroundColor = nil
        
        dateView.translatesAutoresizingMaskIntoConstraints = false
        
        return dateView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(headerView)
        self.addSubview(dateView)
        
        
        
        //dateView.leftAnchor.constraint(equalTo: self.headerView.rightAnchor).isActive = true
        dateView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        dateView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        dateView.bottomAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 30).isActive = true
        dateView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        headerView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 10).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        headerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
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
            // initially set the format based on your datepicker date / server String
            //formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            //let myString = formatter.string(from: date) // string purpose I add here
            // convert your string to date
            //let yourDate = formatter.date(from: myString)
            //then again set the date format whhich type of output you need
            formatter.dateFormat = "dd/MM/yyyy"
            // again convert your date to string
            let myString = formatter.string(from: date)
            dateView.text = myString
        }
    }

}
