//
//  Helpers.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/25/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import Foundation

extension NSDate {
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
}
