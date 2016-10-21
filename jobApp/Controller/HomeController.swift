//
//  HomeController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth

import EZAlertController
import SVProgressHUD

class HomeController: UIViewController {

    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var dataSource:NSMutableDictionary?
    var allJobsIDs:NSArray = []
    
    var jobs10IDs:NSMutableArray = []
    var jobs25IDs:NSMutableArray = []
    var jobs50IDs:NSMutableArray = []
    var jobs100IDs:NSMutableArray = []
   
    var objectIDs:NSArray = []
    
    var msgCcount:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [:]
        
        tabelView.registerNib(UINib.init(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")
        tabelView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeController.locationUpdated), name:"locationUpdated", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeController.postAddNotification), name:"postAddNotification", object: nil)
        
        requestData()
    }
    
    func postAddNotification() {
        NSLog("Notifications example");
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: Requests
    func requestData() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("Jobs").queryOrderedByChild("date").observeEventType(.Value, withBlock: { (snapshot) in
            if snapshot.value == nil {
                return
            }
            
            if let data = snapshot.value as? NSMutableDictionary {
                self.allJobsIDs = data.allKeys
                
                /*100 radius*/
                let ref = FIRDatabase.database().reference().child("JobsLocation")
                
                
                let geoFire = GeoFire(firebaseRef:  ref)
                let query = geoFire.queryAtLocation(userLocation, withRadius: 100)
                
                query.observeEventType(.KeyEntered, withBlock: {
                    (key: String!, location: CLLocation!) in
                        var arr = self.jobs100IDs as NSArray
                        arr = arr.filter{$0 as? String != key}
                        self.jobs100IDs = NSMutableArray.init(array: arr)
                        self.jobs100IDs.addObject(key)
                })
                /*************/
                
                self.dataSource = data
                self.updateData()
            }
        })
    }
    
    
    func findNear(radius:Double) {
        
        let ref = FIRDatabase.database().reference().child("JobsLocation")
        
        
        let geoFire = GeoFire(firebaseRef:  ref)
        let query = geoFire.queryAtLocation(userLocation, withRadius: radius)
        
        query.observeEventType(.KeyEntered, withBlock: {
            (key: String!, location: CLLocation!) in

            if radius == 10 {
                var arr = self.jobs10IDs as NSArray
                arr = arr.filter{$0 as? String != key}
                self.jobs10IDs = NSMutableArray.init(array: arr)
                self.jobs10IDs.addObject(key)
            } else if radius == 25 {
                var arr = self.jobs25IDs as NSArray
                arr = arr.filter{$0 as? String != key}
                self.jobs25IDs = NSMutableArray.init(array: arr)
                self.jobs25IDs.addObject(key)
            } else if radius == 50 {
                var arr = self.jobs50IDs as NSArray
                arr = arr.filter{$0 as? String != key}
                self.jobs50IDs = NSMutableArray.init(array: arr)
                self.jobs50IDs.addObject(key)
            } else if radius == 100 {   //100 radius
                var arr = self.jobs100IDs as NSArray
                arr = arr.filter{$0 as? String != key}
                self.jobs100IDs = NSMutableArray.init(array: arr)
                self.jobs100IDs.addObject(key)
            }
            
            self.updateData()
        })
    }
    
    
    func updateData() {
        
        objectIDs = []
        
        let index = segmentControl.selectedSegmentIndex
        
        if index == 0 {
            objectIDs = allJobsIDs
            //objectIDs = jobs100IDs
        } else if index == 1 {
            objectIDs = jobs10IDs
        } else if index == 2 {
            objectIDs = jobs25IDs
        } else if index == 3 {
            objectIDs = jobs50IDs
        }

        self.tabelView.reloadData()
    }
    
    //MARK:Notificationcell.object = obj
    func locationUpdated() {
        if userLocation != nil {
            findNear(10)
            findNear(25)
            findNear(50)
            findNear(100)       //100 radius
        }
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
        let obj = dataSource!.objectForKey(objID) as? NSDictionary
        cell.object = obj
        
        cell.onDeletePostButtonPressed = {
            self.onDeletePost(objID as String)
        }
        
        
        return cell
    }
    
    func onDeletePost(objID :String){
        
        EZAlertController.alert("Delete this Job Applicant?", message: "", buttons: ["Cancel", "OK"]) { (alertAction, position) -> Void in
            
            if position == 1 {
                let ref = FIRDatabase.database().reference()
                ref.child("Jobs").child(objID).removeValue()
                
                self.tabelView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.jobDetailVC) as! JobDetailViewController
        let objID = objectIDs[indexPath.row] as! NSString
        let obj = dataSource!.objectForKey(objID) as? NSDictionary
        vc.object = obj
        vc.objectID = objID
        
        
        navigationController?.pushViewController(vc, animated: true)
        
        tabelView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    
    //MARK: Action
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        updateData()
    }
    
    @IBAction func accountButtonPressed(sender: UIButton) {
        
        if (FIRAuth.auth()?.currentUser) != nil {
            let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.accountViewController)
            navigationController?.pushViewController(vc!, animated: true)
        } else {
            showLogin()
        }
    }
    
    
    @IBAction func postJobButtonPressed(sender: UIButton) {
        
        if (FIRAuth.auth()?.currentUser) != nil {
            showPostJobController()
            return
        }
        
        EZAlertController.alert("You aren't logged",
                                message: "Only logged user can post jobs",
                                buttons: ["Later", "Login"]) { (alertAction, position) -> Void in
                                    
                                    if position == 1 {
                                        self.showLogin()
                                    }
        }
    }
    
    
    func showLogin() {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.loginNavigationController)
        presentViewController(vc!, animated: true, completion: nil)
    }
    
    func showPostJobController() {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.postNewJobController)
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func onMsgList(sender: UIButton) {
        if (FIRAuth.auth()?.currentUser) != nil {
            let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.jobMsgListVC)
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}
