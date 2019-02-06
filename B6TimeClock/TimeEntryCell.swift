//
//  TimeEntryCell.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class TimeEntryCell: UITableViewCell {

    @IBOutlet weak var beganLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    func configure(timeEntry: TimeEntry) {
        //TODO: format the startTime and duration into strings
        beganLabel.text = "Began: \(timeEntry.startTime)"
    }

}
