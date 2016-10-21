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


class JobDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtInfo: UITextView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    
    
    var object:NSDictionary?
    var objectID:NSString?
    let uid = FIRAuth.auth()!.currentUser!.uid as String
    
    let scrollView = UIScrollView(frame: CGRectMake(0, 0, 600, 260))
    var colors:[UIColor] = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.yellowColor()]
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    var pageControl : UIPageControl = UIPageControl(frame: CGRectMake(100, 200, 200, 50))
    
    var urlList = [String]()
    var urlList_1 = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if object != nil {
            lblTitle.text = (object!["title"]) as? String
            txtInfo.text =  (object!["description"]) as? String
            
            lblPrice.text = "$\((object!["price"]) as! String)"
            lblNumber.text = (object!["zip"]) as? String
            
            if let interval = object!["date"] as? Double {
                let date = NSDate(timeIntervalSince1970: interval)
                lblDate.text = date.dateStringWithFormat("MM/dd/yy")
            }
        }
        
        var index = 0
        
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        let ref = FIRDatabase.database().reference()
        ref.child("Jobs").child(objectID! as String).observeEventType(.Value, withBlock: { (snapshot) in
            let flag = snapshot.hasChild("urlList");
            
            if flag == false {
                /*single photos*/
                self.frame.origin.x = self.scrollView.frame.size.width * CGFloat(0)
                self.frame.size = self.scrollView.frame.size
                self.scrollView.pagingEnabled = true
                let subView = UIImageView(frame: self.frame)
                
                if let urlString = self.object!["photoURL"] {
                    subView.sd_setImageWithURL(NSURL.init(string: urlString as! String))
                }
                self.scrollView.addSubview(subView)
                self.configurePageControl()
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height)
            }
            else {
                /*mutil photos*/
                ref.child("Jobs").child(self.objectID! as String).child("urlList").observeEventType(.Value, withBlock: { (snapshot) in
                    if snapshot.value == nil {
                        return
                    }
                    
                    for element in snapshot.value as! Array<AnyObject> {
                        self.frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
                        self.frame.size = self.scrollView.frame.size
                        self.scrollView.pagingEnabled = true
                        let subView = UIImageView(frame: self.frame)
                        
                        subView.sd_setImageWithURL(NSURL.init(string: element as! String))
                        self.scrollView.addSubview(subView)
                        index = index + 1
                    }
                    self.configurePageControl()
                    
                    let someFloat: CGFloat = CGFloat(index)
                    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * (someFloat), self.scrollView.frame.size.height)
                    
                })
            }
        })
        self.pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        let ref = FIRDatabase.database().reference()
        ref.child("Jobs").child(objectID! as String).observeEventType(.Value, withBlock: { (snapshot) in
            let flag = snapshot.hasChild("urlList")
            
            if flag == false {
                return
            }
            
            ref.child("Jobs").child(self.objectID! as String).child("urlList").observeEventType(.Value, withBlock: { (snapshot) in
                var index = 0
                for element in snapshot.value as! Array<AnyObject> {
                    index = index + 1
                }
                
                self.pageControl.numberOfPages = index
                self.pageControl.currentPage = 0
                self.pageControl.tintColor = UIColor.redColor()
                self.pageControl.pageIndicatorTintColor = UIColor.blackColor()
                self.pageControl.currentPageIndicatorTintColor = UIColor.greenColor()
                self.view.addSubview(self.pageControl)
            })
        })
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
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
