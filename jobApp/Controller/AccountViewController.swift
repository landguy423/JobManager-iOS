//
//  AccountViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import Photos

import Firebase
import FirebaseAuth
import FirebaseStorage

import SDWebImage
import SVProgressHUD
import EZAlertController


class AccountViewController: UIViewController,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var imgUser   : UIImageView!
    
    var textFileds: NSMutableArray?
    var textView:UITextView?
    
    var storageRef:FIRStorageReference!
    var data:NSDictionary?
    
    let cellTitles = ["Name", "Occupation", "Zip Code"]
    
    let ref = FIRDatabase.database().reference()
    let uid = FIRAuth.auth()!.currentUser!.uid as String
    
    
    //MARK: Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib.init(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: "InputCell")
        tableView.registerNib(UINib.init(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        tableView.tableFooterView = UIView()
        
        storageRef = FIRStorage.storage().reference()
        textFileds = NSMutableArray.init(capacity: 3)
        data = [:]
        
        requestUserData()
    }
    
    //MARK: Requests
    func requestUserData() {
        
        SVProgressHUD.show()
        ref.child("UserDetails/\(uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            SVProgressHUD.dismiss()
            if snapshot.value == nil {
                return
            }
            
            if let data = snapshot.value as? NSDictionary {
                self.data = data
                self.tableView.reloadData()
                
                if let urlString = self.data!["photoURL"] {
                    self.imgUser.sd_setImageWithURL(NSURL.init(string: urlString as! String))
                }
            }
        })
    }
    
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell") as! DescriptionCell!
            if let text = data!["description"] {
                cell.txtData.text = text as? String
            }
            textView = cell.txtData
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell!
        
        let title = cellTitles[indexPath.row] as String
        cell.lblTitle.text = title
        if indexPath.section == 0 {
            textFileds![indexPath.row] = cell.txtInput
            if cell.lblTitle.text == "Name" {
                cell.txtInput.userInteractionEnabled = false
                cell.txtInput.text = "0"
            }
            if cell.lblTitle.text == "Zip Code" {
                cell.txtInput.delegate = self
                /*cell.txtInput.characters.count = 5
                if (cell.txtInput.text!.characters.count > 5) {
                    cell.txtInput.endEditing(true)
                }*/
            }
        }
        
        
        if let text = data![title.lowercaseString] {
            cell.txtInput.text = text as? String
        }
        
        if indexPath.section == 2 {//completed job
            cell.txtInput.userInteractionEnabled = false
            cell.lblTitle.text = "Completed jobs"
            if let jobs = data!["jobsCompleted"] as? NSDictionary {
                cell.txtInput.text = "\(jobs.allKeys.count)"
            } else {
                cell.txtInput.text = "0"
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            return 100
        }
        
        return 44
    }
    
    //MARK: Action
    @IBAction func confirmButtonPressed(sender: UIButton) {

        for textfield in textFileds! {
            if (textfield as! UITextField).text!.characters.count == 0 {
                EZAlertController.alert("Error", message: "Enter all info")
                return
            }
        }
        
        if textView?.text.characters.count == 0 {
            EZAlertController.alert("Error", message: "Enter all info")
            return
        }
        
        ref.child("UserDetails/\(uid)/name").setValue(textFileds![0].text)
        ref.child("UserDetails/\(uid)/occupation").setValue(textFileds![1].text)
        ref.child("UserDetails/\(uid)/zip").setValue(textFileds![2].text)
        ref.child("UserDetails/\(uid)/description").setValue(textView!.text)
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            navigationController?.popViewControllerAnimated(true)
        } catch let signOutError as NSError {
            EZAlertController.alert("Error", message: signOutError.localizedDescription)
        }
    }
    
    
    //MARK: Add photo
    @IBAction func addPhotoSelected(sender: UIButton) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Select photo", message: "", preferredStyle: .ActionSheet)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in}
        actionSheetController.addAction(cancelAction)
        
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            self.didTapTakePicture( true)
        }
        actionSheetController.addAction(takePictureAction)
        
        
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
            self.didTapTakePicture(false)
        }
        actionSheetController.addAction(choosePictureAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    func didTapTakePicture(takePicture: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = takePicture ? UIImagePickerControllerSourceType.Camera : UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(picker, animated: true, completion:nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imagePath = uid + "/\(CLongLong(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        
        self.imgUser.image = image
        
        metadata.contentType = "image/jpeg"
        self.storageRef.child(imagePath)
            .putData(imageData!, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    EZAlertController.alert("Error", message: error!.localizedDescription)
                    return
                }
                
                //add URL to database
                self.ref.child("UserDetails/\(self.uid)/photoURL").setValue(metadata!.downloadURL()!.absoluteString)
        }
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 5
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
         
    }
    
}