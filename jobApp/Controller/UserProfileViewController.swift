//
//  UserProfileViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOcupation: UILabel!
    
    @IBOutlet weak var lblJobs: UILabel!
    @IBOutlet weak var txtInfo: UITextView!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    var object:NSDictionary?
    var objectID:NSString?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInfo()
    }
    
    
    func updateUserInfo() {
        if object != nil {
            lblName.text = (object!["email"]) as? String
            
            if let occ = object!["occupation"] {
                lblOcupation.text = occ as? String
            }
            
            txtInfo.text =  (object!["description"]) as? String
            
            if let urlString = object!["photoURL"] {
                imgPhoto.sd_setImageWithURL(NSURL.init(string: urlString as! String))
            }
            
            if let jobs = object!["jobsCompleted"] as? NSDictionary {
                lblJobs.text = "\(jobs.allKeys.count)"
            } else {
                lblJobs.text = "0"
            }
        }
    }
    

}
