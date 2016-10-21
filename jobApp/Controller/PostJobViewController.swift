//
//  PostJobViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import Firebase

import EZAlertController
import SVProgressHUD

class PostJobViewController: UITableViewController,
                             UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let cellTitles = ["Title", "Zip Code", "$"]
    
    var textFileds: NSMutableArray?
    var textView:UITextView?
    
    var stringURL:NSString?
    var photo:UIImage?
    
    var date:NSDate?
    
    var index:NSInteger?
    
    var urlList = [String]()
    
    //MARK: Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib.init(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: "InputCell")
        tableView.registerNib(UINib.init(nibName: "DateCell", bundle: nil), forCellReuseIdentifier: "DateCell")
        tableView.registerNib(UINib.init(nibName: "AddPictureCell", bundle: nil), forCellReuseIdentifier: "AddPictureCell")
        tableView.registerNib(UINib.init(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        
        tableView.tableFooterView = UIView()
        
        textFileds = NSMutableArray.init(capacity: 3)
    }
    
    
    //MARK:Post data
    func postInfo() {
        
        for textfield in textFileds! {
            if (textfield as! UITextField).text!.characters.count == 0 {
                EZAlertController.alert("Error", message: "Enter all info")
                return
            }
        }
        
        if textView!.text.characters.count == 0 {
            EZAlertController.alert("Error", message: "Enter all info")
            return
        }
        
        if userLocation == nil {
            EZAlertController.alert("Error", message: "You need allow location if you want post jobs")
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        let jobID = String(CLongLong(NSDate().timeIntervalSince1970 * 1000))
        
        let data: NSMutableDictionary = [:]
        
        data.setDictionary(["user"        : uid,
                            "postDate"    : NSNumber(double: NSDate().timeIntervalSince1970),
                            "title"       : textFileds![0].text,
                            "zip"         : textFileds![1].text,
                            "price"       : textFileds![2].text,
                            "description" : textView!.text,])
        
        if stringURL?.length > 0 {
            data.setValue(stringURL, forKey: "photoURL")
        }
        
        if urlList.count > 0 {
            data.setValue(urlList, forKey: "urlList")
        }
        
        if date != nil {
            data.setValue(NSNumber(double: date!.timeIntervalSince1970), forKey: "date")
        }
        
        ref.child("Jobs").child(jobID).setValue(data)
        
        ref.child("UserDetails").child(uid).child("jobsPosted").child(jobID).setValue(true)
        
        let geoFireRef = GeoFire(firebaseRef: ref.child("JobsLocation"))
        geoFireRef.setLocation(userLocation, forKey: jobID)
        
        NSNotificationCenter.defaultCenter().postNotificationName("postAddNotification", object: nil)
    }
    
    
    
    //MARK: TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 3 :1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
       
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell!
            
            let titleText = cellTitles[indexPath.row]
            cell.lblTitle.text = titleText
            
            if titleText == "Zip Code" {
                cell.txtInput.delegate = self
            }
            if titleText == "$" || titleText == "Zip Code" {
                cell.txtInput.keyboardType = UIKeyboardType.NumberPad
            }
            
            textFileds![indexPath.row] = cell.txtInput
            return cell
            
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("DateCell") as! DateCell!
            cell.onDateSelected = {  (date:NSDate) -> Void in
                self.date = date
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell") as! DescriptionCell!
            textView = cell.txtData
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("AddPictureCell") as! AddPictureCell!
            
            if photo != nil {
                cell.imgPhoto.image = photo
            }
            
            cell.onAddPhotButtonPressed = {
                self.postPicturebuttonPressed()
            }
            return cell

            
        default:
            return UITableViewCell.init()
        }

    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            return 100
        }
        
        return 44
    }
    
    
    //MARK: Action
    @IBAction func confirmButtonPressed(sender: UIButton) {
        postInfo()
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func postPicturebuttonPressed() {
        
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
        
        let uid = FIRAuth.auth()!.currentUser!.uid as String
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imagePath = uid + "/\(CLongLong(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        
        photo = image
        tableView.reloadData()
        
        SVProgressHUD.showWithStatus("Image processing...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Gradient)
        
        metadata.contentType = "image/jpeg"
        let storageRef = FIRStorage.storage().reference()
        storageRef.child(imagePath)
            .putData(imageData!, metadata: metadata) { (metadata, error) in
                
                SVProgressHUD.dismiss()
                if error != nil {
                    EZAlertController.alert("Error", message: error!.localizedDescription)
                    return
                }

                //add URL to database
                self.stringURL = metadata!.downloadURL()!.absoluteString
                
                self.urlList.append(self.stringURL! as String)
        }
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
    //Set length of ZipCode textfield's
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