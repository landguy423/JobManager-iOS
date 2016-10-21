//
//  JobMsgListViewController.swift
//  jobApp
//
//  Created by Pavlo Bondarenko on 7/6/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

import Firebase

import EZAlertController
import SVProgressHUD


class JobMsgListViewController: UIViewController {
    var dataSource:NSMutableDictionary?
    var emailList = [String]()
    var ownerAddr:String?
    var ownerImage:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [:]
        
        tableView.registerNib(UINib.init(nibName: "MsgCell", bundle: nil), forCellReuseIdentifier: "MsgCell")
        tableView.tableFooterView = UIView()
        
        requestData()
    }
    
    
    //MARK: Requests
    func requestData() {
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        
        let userRef = FIRDatabase.database().reference().child("UserDetails")
        
        userRef.observeEventType(.Value, withBlock: { (snapshot1) in
                if let data = snapshot1.value as? NSMutableDictionary {
                    
                    for item in data {
                        print(item)
                        if item.key.description != uid {
                            if (item.value["email"] != nil) {
                                let val = item.value["email"].description
                                self.emailList.append(val)
                            }
                                                    }
                        else {
                            if (item.value["photoURL"] != nil) {
                                self.ownerImage = item.value["photoURL"].description
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            
        })
    }
    
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MsgCell") as! MsgCell!
        let email = emailList[indexPath.row]
        cell.email_addr = email
        
        if (self.ownerImage != nil) {
            cell.imgUser.sd_setImageWithURL(NSURL.init(string: self.ownerImage!))
        }
        return cell
    }
 
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.ControllerIDs.msgRoomVC) as! MessageRoomController
        vc.to_email = emailList[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
}
