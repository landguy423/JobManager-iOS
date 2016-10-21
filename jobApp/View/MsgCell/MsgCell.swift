//
//  JobCell.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import SDWebImage

class MsgCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!
    
    var email_addr:String? {
        
        didSet {
            
            if email_addr != nil {
                lblInfo.text =  email_addr
                /*
                if let urlString = object!["photoURL"] {
                    imgUser.sd_setImageWithURL(NSURL.init(string: urlString as! String))
                }*/
            }
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.cornerRadius = 5.0
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()

        //imgUser.image = UIImage.init(named: "default_placeholder.png")
        lblInfo.text = nil
    }
}
