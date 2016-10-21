//
//  MyJobCell.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/29/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

class MyJobCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblZipcode: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var acceptButtonWdth: NSLayoutConstraint!
    var onDeleteButtonPressed:(() -> Void)?
    var onMessageButtonPressed:(() -> Void)?
    var onAcceptButtonPressed:(() -> Void)?
    
    var object:NSDictionary? {
        
        didSet {
            
            if object != nil {
                
                lblTitle.text = (object!["title"]) as? String
                lblInfo.text =  (object!["description"]) as? String
                lblPrice.text = "$\((object!["price"]) as! String)"
                lblZipcode.text =  (object!["zip"]) as? String
                
                if let interval = object!["date"] as? Double {
                    let date = NSDate(timeIntervalSince1970: interval)
                    lblDate.text = date.dateStringWithFormat("MM/dd/yy")
                }
                
                //lblAmount.text =  (object!["amount"]) as? String
                
                if let urlString = object!["photoURL"] {
                    imgUser.sd_setImageWithURL(NSURL.init(string: urlString as! String))
                }
            }
            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    //MARK:Aation
    @IBAction func messageButtonPressed(sender: UIButton) {
        onMessageButtonPressed!()
    }
    
    @IBAction func deleteButtonPressed(sender: UIButton) {
        onDeleteButtonPressed!()
    }
    
    @IBAction func acceptButtonPressed(sender: UIButton) {
        onAcceptButtonPressed!()
    }
}
