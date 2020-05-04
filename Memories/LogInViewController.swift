//
//  LoggedInViewController.swift
//  Memories
//
//  Created by Renat Nurtdinov on 02.05.2020.
//  Copyright © 2020 Renat Nurtdinov. All rights reserved.
//

import Parse
import UIKit

class LogInViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        // Do any additional setup after loading the view.
    }
    @IBOutlet fileprivate var signUpUsernameField: UITextField!
    @IBOutlet fileprivate var signUpPasswordField: UITextField!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewDidAppear(_ animated: Bool) {
        let currentUser = PFUser.current()
        if currentUser != nil {
            loadHomeScreen()
        }
    }
}
