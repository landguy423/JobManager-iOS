//
//  JobDetailViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

import EZAlertController


class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var ibgPhoto: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtInfo: UITextView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    
    
    var object:NSDictionary?
    var objectID:NSString?
    let uid = FIRAuth.auth()!.currentUser!.uid as String
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if object != nil {
            lblTitle.text = (object!["title"]) as? String
            txtInfo.text =  (object!["description"]) as? String
            
            lblPrice.text = "$\((object!["price"]) as! String)"
            lblNumber.text = (object!["zip"]) as? String
            
            if let urlString = object!["photoURL"] {
                ibgPhoto.sd_setImageWithURL(NSURL.init(string: urlString as! String))
            }
            
            if let interval = object!["date"] as? Double {
                let date = NSDate(timeIntervalSince1970: interval)
                lblDate.text = date.dateStringWithFormat("MM/dd/yy")
            }
        }
    }
    
    
    //MARK: Action
    @IBAction func applyButtonPressed(sender: UIButton) {
        if uid == object!["user"] as? NSString {
            EZAlertController.alert("Error", message: "You cannot apply to job that you post")
        } else {
            showPriceAlert()
        }
    }
    
    
    //MARK: Selectors
    func showPriceAlert() {
        let passwordPrompt = UIAlertController(title: "Enter Price", message: "$", preferredStyle: UIAlertControllerStyle.Alert)
        passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            let textField = passwordPrompt.textFields![0] as UITextField
            
            let text = textField.text
            if text?.characters.count == 0 {
                EZAlertController.alert("Add price", message: "")
            } else {
                self.applyOnJob(text!)
            }
        }))
        
        passwordPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Amount"
            textField.keyboardType = UIKeyboardType.NumberPad
        })
        
        presentViewController(passwordPrompt, animated: true, completion: nil)
    }
    
    
    func applyOnJob(price:NSString) {
        
        let ref = FIRDatabase.database().reference()
        
        let data: NSMutableDictionary = [:]
        
        data.setDictionary(["user"        : uid,
            "postDate"    : NSNumber(double: NSDate().timeIntervalSince1970),
            "jobId"       : objectID!,
            "price"      : price])
 
        
        ref.child("JobApplication").child(objectID! as String).child(uid).setValue(data)
       
        ref.child("Jobs").child(objectID! as String).child("applicants").child(uid).setValue(true)
        ref.child("UserDetails").child(uid).child("jobsApplied").child(objectID! as String).setValue(true)
        
        EZAlertController.alert("You Applied to the Job!", message: "", buttons: ["OK"]) { (alertAction, position) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    
    }
    
    /*goto add post page*/
    @IBAction func onGotoAddPost(sender: AnyObject) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.postNewJobController)
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}
