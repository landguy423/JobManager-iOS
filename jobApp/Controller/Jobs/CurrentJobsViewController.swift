//
//  CurrentJobsViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/29/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import Firebase

import EZAlertController
import SVProgressHUD


class CurrentJobsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControll: UISegmentedControl!

    var dataSourceClient:NSMutableDictionary?
    var objectIDsClient:NSMutableArray = []
    
    var dataSourceWorker:NSMutableDictionary?
    var objectIDsWorker:NSMutableArray = []
    
    var dataSource:NSMutableDictionary?
    var objectIDs:NSMutableArray = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [:]
        dataSourceClient = [:]
        dataSourceWorker = [:]
        
        tableView.registerNib(UINib.init(nibName: "MyJobCell", bundle: nil), forCellReuseIdentifier: "MyJobCell")
        tableView.tableFooterView = UIView()
        
        requestClientData()
        requestWorkerData()
    }
    
    
    //MARK: Requests
    func requestClientData() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        let userRef = FIRDatabase.database().reference().child("UserDetails").child(uid).child("jobsClient")
        let jobsRef = FIRDatabase.database().reference().child("CurrentJobs")
        
        userRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            jobsRef.child(snapshot.key).observeEventType(.Value, withBlock: { (snapshot1) in
                
                if let data = snapshot1.value as? NSMutableDictionary {
                    
                    var arr = self.objectIDsClient as NSArray
                    arr = arr.filter{$0 as? String != snapshot.key}
                    self.objectIDsClient = NSMutableArray.init(array: arr)
                    self.objectIDsClient.addObject(snapshot.key)
                    
                    self.dataSourceClient?.setObject(data, forKey: snapshot.key)
                    
                    self.updateUI()
                }
            });
            
        })
    }
    
    func requestWorkerData() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        let userRef = FIRDatabase.database().reference().child("UserDetails").child(uid).child("jobsWorker")
        let jobsRef = FIRDatabase.database().reference().child("CurrentJobs")
        
        userRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            jobsRef.child(snapshot.key).observeEventType(.Value, withBlock: { (snapshot1) in
                
                if let data = snapshot1.value as? NSMutableDictionary {
                    
                    var arr = self.objectIDsWorker as NSArray
                    arr = arr.filter{$0 as? String != snapshot.key}
                    self.objectIDsWorker = NSMutableArray.init(array: arr)
                    self.objectIDsWorker.addObject(snapshot.key)
                    
                    self.dataSourceWorker?.setObject(data, forKey: snapshot.key)
                    
                    self.updateUI()
                }
            });
            
        })
    }
    
    
    func updateUI() {
        
        let index = segmentControll.selectedSegmentIndex
        
        if index == 0 {
            objectIDs = objectIDsClient
            dataSource = dataSourceClient
        } else if index == 1 {
            objectIDs = objectIDsWorker
            dataSource = dataSourceWorker
        }

        self.tableView.reloadData()
    }
    

    //MARK:Action
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        updateUI()
    }
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MyJobCell") as! MyJobCell!
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        cell.acceptButtonWdth.constant = 30
        cell.object = obj
        cell.onMessageButtonPressed = {
            self.openMessages(indexPath.row)
        }
        
        cell.onDeleteButtonPressed = {
            self.deleteApplicant(indexPath.row)
        }
        
        cell.onAcceptButtonPressed = {
            self.confirmUser(indexPath.row)
        }
        
        
        return cell
    }
    
    func deleteApplicant(index:NSInteger) {
        
        EZAlertController.alert("Delete this Job?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                
                let objID = self.objectIDs[index] as! String
                ref.child("CurrentJobs").child(objID).removeValue()
                //in user?
                
                self.navigationController?.popToRootViewControllerAnimated(true)
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
        let object = dataSource?.objectForKey(objID) as! NSDictionary
        
        vc.jobID = objID
        
        let owner = object["user"] as! String
        vc.receiverID =  (owner == uid) ? ((object["worker"]) as! String) : owner
        vc.jobOwnerID = owner
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmUser(index:NSInteger) {
        
        EZAlertController.alert("Job has been Completed?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                
                let objID = self.objectIDs[index] as! String
                ref.child("CurrentJobs").child(objID).removeValue()
                //in user?
                
                let object = self.dataSource?.objectForKey(objID) as! NSDictionary
                ref.child("UserDetails").child((object["worker"]) as! String).child("jobsCompleted").child(objID).setValue(true)
                
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }

    @IBAction func onGotoJobPosting(sender: AnyObject) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.postNewJobController)
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}
