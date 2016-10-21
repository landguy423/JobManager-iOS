//
//  DateCell.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/25/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit

class DateCell: UITableViewCell {

    @IBOutlet weak var txtField: UITextField!
    let dateFormat: NSDateFormatter = NSDateFormatter()
    let datePicker: UIDatePicker = UIDatePicker()
    
    var onDateSelected:((NSDate) -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormat.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormat.timeStyle = NSDateFormatterStyle.ShortStyle
        datePicker.datePickerMode = UIDatePickerMode.Date
        txtField.inputView = datePicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor.blackColor()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(DateCell.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(DateCell.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        txtField.inputAccessoryView = toolBar
    }
    
    
    func doneClick() {
        txtField.resignFirstResponder()

        onDateSelected!(datePicker.date)

        txtField.text = datePicker.date.dateStringWithFormat("MM/dd/yy")
    }
    
    
    func cancelClick() {
        txtField.resignFirstResponder()
    }
    
}
