//
//  PostingJobsViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/29/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

import Firebase

import EZAlertController
import SVProgressHUD


class PostingJobsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource:NSMutableDictionary?
    var objectIDs:NSMutableArray = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [:]
        
        tableView.registerNib(UINib.init(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")
        tableView.tableFooterView = UIView()
        
        requestData()
    }
    
    
    //MARK: Requests
    func requestData() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        let userRef = FIRDatabase.database().reference().child("UserDetails").child(uid).child("jobsPosted")
        let jobsRef = FIRDatabase.database().reference().child("Jobs")
        
        userRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            jobsRef.child(snapshot.key).observeEventType(.Value, withBlock: { (snapshot1) in
                
                if let data = snapshot1.value as? NSMutableDictionary {
                    var arr = self.objectIDs as NSArray
                    arr = arr.filter{$0 as? String != snapshot.key}
                    self.objectIDs = NSMutableArray.init(array: arr)
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("JobCell") as! JobCell!
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        cell.object = obj
        
        cell.onDeletePostButtonPressed = {
            self.onDeletePost(objID as String)
        }
        
        return cell
    }
    
    func onDeletePost(objID :String) {
        
        EZAlertController.alert("Delete this Job Applicant?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                ref.child("Jobs").child(objID).removeValue()
                
                self.tableView.reloadData()
            }
        }
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.postedJobDetailControler) as! PostingJobDetailViewController
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        vc.object = obj
        vc.objectID = objID
        
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    @IBOutlet weak var onGotoJobPosting: UIBarButtonItem!
    @IBAction func onGotoJobPosting(sender: AnyObject) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.postNewJobController)
        navigationController?.pushViewController(vc!, animated: true)
    }
}
