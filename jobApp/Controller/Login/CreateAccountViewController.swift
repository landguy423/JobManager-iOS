//
//  CreateAccountViewController.swift
//  Firebase Login Xcode 7.2
//
//  Created by PJ Vea on 3/1/16.
//  Copyright © 2016 Vea Software. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import EZAlertController


class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //MARK: Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: Actions
    @IBAction func createAccountAction(sender: AnyObject) {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        
        if email == "" || password == "" {
            EZAlertController.alert("Error", message: "Enter Email and Password.")
            return
            
        }
        
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            
            if let error = error {
                EZAlertController.alert("Error", message: error.localizedDescription)
                return
            }
            
            let ref = FIRDatabase.database().reference()
            let uid = FIRAuth.auth()!.currentUser!.uid as String
            ref.child("UserDetails/\(uid)/email").setValue(FIRAuth.auth()!.currentUser!.email)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
