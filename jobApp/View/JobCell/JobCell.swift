//
//  JobCell.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import SDWebImage

class JobCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    
    var onDeletePostButtonPressed:(() -> Void)?
    
    @IBAction func onDeletePost(sender: AnyObject) {
        onDeletePostButtonPressed!()
    }
    
    var object:NSDictionary? {
        
        didSet {
            
            if object != nil {
                lblTitle.text = (object!["title"]) as? String
                lblInfo.text =  (object!["description"]) as? String
                
                lblPrice.text = "$\((object!["price"]) as! String)"
                lblNumber.text = (object!["zip"]) as? String
                
                if let urlString = object!["photoURL"] {
                    imgUser.sd_setImageWithURL(NSURL.init(string: urlString as! String))
                }
                
                if let interval = object!["date"] as? Double {
                    let date = NSDate(timeIntervalSince1970: interval)
                    lblDate.text = date.dateStringWithFormat("MM/dd/yy")
                }
            }
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.cornerRadius = 5.0
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imgUser.image = UIImage.init(named: "default_placeholder.png")
        lblTitle.text = nil
        lblInfo.text = nil
        
        lblDate.text = nil
        lblPrice.text = nil
        lblNumber.text = nil
    }
}
