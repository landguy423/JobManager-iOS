//
//  LoginViewController.swift
//  Firebase Login Xcode 7.2
//
//  Created by PJ Vea on 3/1/16.
//  Copyright © 2016 Vea Software. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import EZAlertController

class LoginViewController: UIViewController
{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginAction(sender: AnyObject)
    {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        
        if email != "" && password != "" {
            
            FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
                
                if error == nil {
                    let ref = FIRDatabase.database().reference()
                    let uid = FIRAuth.auth()!.currentUser!.uid as String
                    ref.child("UserDetails/\(uid)/email").setValue(FIRAuth.auth()!.currentUser!.email)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    EZAlertController.alert("Error", message: (error?.localizedDescription)!)
                }
            }
        } else {
            EZAlertController.alert("Error", message: "Enter Email and Password.")
        }
    }
    
}
