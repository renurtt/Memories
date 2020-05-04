//
//  SignUpViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 03.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import Parse
import UIKit

class SignUpViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        // Do any additional setup after loading the view.
    }
    @IBOutlet fileprivate var signUpUsernameField: UITextField!
    @IBOutlet fileprivate var signUpPasswordField: UITextField!
    
    @IBAction func signUp(_ sender: UIButton) {
        let user = PFUser()
        user.username = signUpUsernameField.text
        user.password = signUpPasswordField.text
        let sv = UIViewController.displaySpinner(onView: self.view, darkenBack: true)
        user.signUpInBackground { (success, error) in
            UIViewController.removeSpinner(spinner: sv)
            if success{
                self.loadHomeScreen()
            }else{
                if let descrip = error?.localizedDescription{
                    self.displayErrorMessage(message: descrip)
                }
            }
        }
    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func loadHomeScreen(){
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? UITabBarController {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
        }
    }

    
}
