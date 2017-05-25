//
//  CustomCell.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/23/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
}
