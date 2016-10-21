//
//  ApplyingJobController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/29/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import Firebase
import EZAlertController

class ApplyingJobController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource:NSMutableDictionary?
    var objectIDs:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [:]
        
        tableView.registerNib(UINib.init(nibName: "MyJobCell", bundle: nil), forCellReuseIdentifier: "MyJobCell")
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    
    //MARK: Requests
    func requestData() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        let userRef = FIRDatabase.database().reference().child("UserDetails").child(uid).child("jobsApplied")
        let jobsRef = FIRDatabase.database().reference().child("Jobs")
        
        /*let ref = FIRDatabase.database().reference().child("Messages")
        ref.observeEventType(.Value, withBlock: { (snapshot) in
            jobsRef.child(snapshot.key).observeEventType(.Value, withBlock: { (snapshot1) in
                for rest in snapshot.children { //ERROR: "NSEnumerator" does not have a member named "Generator"
                    for rest1 in rest.children { //ERROR: "NSEnumerator" does not have a member named "Generator"
                        for rest2 in rest1.children { //ERROR: "NSEnumerator" does not have a member named "Generator"
                            for rest3 in rest2.children { //ERROR: "NSEnumerator" does not have a member named "Generator"
                            }
                        }
                    }

                }
            });
        })*/
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MyJobCell") as! MyJobCell!
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        cell.object = obj
        cell.onMessageButtonPressed = {
            self.openMessages(indexPath.row)
        }
        
        cell.onDeleteButtonPressed = {
            self.deleteApplicant(objID as String)
        }
        
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        let ref = FIRDatabase.database().reference()
        ref.child("JobApplication").child(objID as! String).child(uid as String).observeEventType(.Value, withBlock: { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                let price = data["price"] as! String
                cell.lblAmount.text = price
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func deleteApplicant(objectID:String!) {
        
        
        EZAlertController.alert("Delete this Application?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                
                let uid = FIRAuth.auth()!.currentUser!.uid as String
                
                ref.child("JobApplication").child(objectID).child(uid).removeValue()
                
                ref.child("Jobs").child(objectID).child("applicants").child(uid).removeValue()
                ref.child("UserDetails").child(uid).child("jobsApplied").child(objectID).removeValue()
                
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    
    func openMessages(index:NSInteger) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.messageVC) as! MessagesViewController
        let objID = objectIDs[index] as! NSString
        let obj = dataSource?.objectForKey(objID) as? NSDictionary
        vc.jobID = objID
        vc.receiverID = (obj!["user"]) as! NSString
        vc.jobOwnerID = (obj!["user"]) as! NSString

        navigationController?.pushViewController(vc, animated: true)
    }
    


}

