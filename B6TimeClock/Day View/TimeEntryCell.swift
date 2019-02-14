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

    var entry: TimeEntry?

    func configure(timeEntry: TimeEntry) {
        entry = timeEntry
        
        beganLabel.text = timeEntry.startTime.formattedTime()
        durationLabel.text = timeEntry.durationString()

        NotificationCenter.default.addObserver(self, selector: #selector(TimeEntryCell.updateTimer),
                                               name: TimerNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateTimer(_ notification: Notification) {
        if let timeEntry = entry, timeEntry.stopTime == nil {
            durationLabel.text = timeEntry.durationString()
        }
    }

}
