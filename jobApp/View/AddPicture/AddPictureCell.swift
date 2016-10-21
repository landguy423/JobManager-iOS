//
//  AddPictureCell.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/25/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

class AddPictureCell: UITableViewCell {

    @IBOutlet weak var imgPhoto: UIImageView!
      var onAddPhotButtonPressed:(() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }


    @IBAction func addPhotButtonPressed(sender: UIButton) {
        onAddPhotButtonPressed!()
    }
    
}
