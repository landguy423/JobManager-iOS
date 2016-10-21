//
//  PostingJobDetailViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/29/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

import Firebase

import SDWebImage
import EZAlertController


class PostingJobDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgPhot: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtInfo: UITextView!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtPrice: UILabel!
    @IBOutlet weak var txtZipcode: UILabel!
    
    var dataSource:NSMutableDictionary?
    var objectIDs:NSMutableArray = []
    
    var object:NSDictionary?
    var objectID:NSString?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hhh", objectID)
        title = "Job Details"
        
        dataSource = [:]
        
        tableView.registerNib(UINib.init(nibName: "ApplicantCell", bundle: nil), forCellReuseIdentifier: "ApplicantCell")
        tableView.tableFooterView = UIView()
        
        updateDetails()
        requestData()
    }
    
    
    func updateDetails() {
        if object != nil {
            print(object)
            lblTitle.text = (object!["title"]) as? String
            txtInfo.text =  (object!["description"]) as? String
            txtPrice.text =  (object!["price"]) as? String
            //txtZipcode.text =  (object!["zip"]) as? String
            txtZipcode.text =  "aaa"
            
            if let interval = object!["date"] as? Double {
                let date = NSDate(timeIntervalSince1970: interval)
                txtDate.text = date.dateStringWithFormat("MM/dd/yy")
            }

            
            if let urlString = object!["photoURL"] {
                imgPhot.sd_setImageWithURL(NSURL.init(string: urlString as! String))
            }
        }
    }
    
    //MARK: Requests
    func requestData() {
        
        let jobsRef = FIRDatabase.database().reference().child("Jobs").child(objectID! as String).child("applicants")
        let userRef = FIRDatabase.database().reference().child("UserDetails")
    
        jobsRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            userRef.child(snapshot.key).observeEventType(.Value, withBlock: { (snapshot1) in
                
                if let data = snapshot1.value as? NSMutableDictionary {
                    self.objectIDs.addObject(snapshot.key)
                    self.dataSource?.setObject(data, forKey: snapshot.key)
                    self.tableView.reloadData()
                }
            });
            
        })
    }
    
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ApplicantCell") as! ApplicantCell!
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        cell.object = obj

        cell.onDeleteButtonPressed = {
            self.deleteApplicant(objID as String)
        }
        
        cell.onMessageButtonPressed = {
            self.openMessages(indexPath.row)
        }
        
        cell.onConfirmButtonPressed = {
            self.confirmUser(indexPath.row)
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("JobApplication").child(objectID as! String).child(objID as String).observeEventType(.Value, withBlock: { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                let price = data["price"] as! String
                cell.lblPrice.text = "$\(price)"
            }
        })
        
        return cell
    }
    
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        return "Applicants"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.profileVC) as! UserProfileViewController
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        vc.objectID = objID
        vc.object = obj
        
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func deleteApplicant(uid:String!) {
        
        EZAlertController.alert("Delete this Job Applicant?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
           
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                
                ref.child("JobApplication").child(self.objectID as! String).child(uid).removeValue()
                
                ref.child("Jobs").child(self.objectID as! String).child("applicants").child(uid).removeValue()
                ref.child("UserDetails").child(uid).child("jobsApplied").child(self.objectID as! String).removeValue()
                
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func openMessages(index:NSInteger) {
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.messageVC) as! MessagesViewController
        let objID = objectIDs[index] as! NSString
        vc.jobID = objectID
        vc.receiverID = objID
        vc.jobOwnerID = uid
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmUser(index:NSInteger) {
        
        EZAlertController.alert("Approve this Job Applicant?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            if position == 1 {
                let objID = self.objectIDs[index] as! String
                let uid = FIRAuth.auth()!.currentUser!.uid as String
                
                let ref = FIRDatabase.database().reference()
                
                ////add new
                ref.child("CurrentJobs").child(self.objectID as! String).setValue(self.object!)
                ref.child("CurrentJobs").child(self.objectID as! String).child("worker").setValue(objID)
                ref.child("UserDetails").child(objID).child("jobsWorker").child(self.objectID as! String).setValue(true)
                ref.child("UserDetails").child(uid).child("jobsClient").child(self.objectID as! String).setValue(true)
                
                //remove old
                ref.child("Jobs").child(self.objectID as! String).removeValue()
                ref.child("JobApplication").child(self.objectID as! String).removeValue()
                ref.child("UserDetails").child(objID).child("jobsApplied").child(self.objectID as! String).removeValue()
                ref.child("UserDetails").child(uid).child("jobsPosted").child(self.objectID as! String).removeValue()
                
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func onDeletePost(sender: AnyObject) {
        self.DeletePost(self.objectID as! String)
    }
    
    func DeletePost(objID :String){
        
        EZAlertController.alert("Delete this Job Post?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                ref.child("Jobs").child(objID).removeValue()
                
                //let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.postingJobsVC)
                //navigationController?.pushViewController(vc!, animated: true)
                self.navigationController?.popToRootViewControllerAnimated(true)
                //self.tableView.reloadData()
            }
        }
    }
}

