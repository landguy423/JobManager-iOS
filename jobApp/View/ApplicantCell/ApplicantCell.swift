//
//  ApplicantCell.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/17/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import SDWebImage

class ApplicantCell: UITableViewCell {

    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    var onConfirmButtonPressed:(() -> Void)?
    var onDeleteButtonPressed:(() -> Void)?
    var onMessageButtonPressed:(() -> Void)?
    
    
    var object:NSDictionary? {
        
        didSet {
            
            if object != nil {
                
                if let name = object!["name"] {
                    lblName.text = name as? String
                }else if let email = object!["email"] {
                    lblName.text = email as? String
                }
                
                if let urlString = object!["photoURL"] {
                    imgPhoto.sd_setImageWithURL(NSURL.init(string: urlString as! String))
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgPhoto.layer.cornerRadius = CGRectGetHeight(imgPhoto.bounds) / 2.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblName.text = nil
    }
    

    
    //MARK: Actions
    @IBAction func checkButtonPressed(sender: UIButton) {
        onConfirmButtonPressed!()
    }
    
    @IBAction func deleteButtonPressed(sender: UIButton) {
        onDeleteButtonPressed!()
    }
    
    @IBAction func messageButtonPressed(sender: UIButton) {
        onMessageButtonPressed!()
    }
}
