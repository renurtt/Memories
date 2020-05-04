//
//  Extensions.swift
//  Memories
//
//  Created by Renat Nurtdinov on 03.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import UIKit

extension UIViewController {
    class func displaySpinner(onView : UIView, darkenBack : Bool) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        if darkenBack {
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        }
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
