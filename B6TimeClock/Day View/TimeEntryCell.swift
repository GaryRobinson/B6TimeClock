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
    var timer: Timer?
    
    func configure(timeEntry: TimeEntry) {
        entry = timeEntry
        
        //TODO: format the startTime and duration into strings
        beganLabel.text = "Started: \(timeEntry.startTime.formattedTime())"
        durationLabel.text = "Duration: \(timeEntry.durationString())"

        //TODO: timer to update the duration if its active
        // need a good way to stop it too
        if timeEntry.stopTime == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                self.updateTimer()
            })
        }
    }

    deinit {
        timer?.invalidate()
    }

    func updateTimer() {
        if let timeEntry = entry {
            durationLabel.text = "Duration: \(timeEntry.durationString())"
        }
    }

}
