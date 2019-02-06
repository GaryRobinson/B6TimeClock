//
//  SectionHeaderCell.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var leftTimeTitle: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var centerTimeTitle: UILabel!
    @IBOutlet weak var centerTimeLabel: UILabel!
    @IBOutlet weak var rightTimeTitle: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var entryType = TimeEntryType.Shift
    var isTrackingDuration = false

    func configure(type: TimeEntryType) {
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.white.cgColor
        addButton.layer.cornerRadius = 5

        entryType = type
        sectionTitleLabel.text = entryType.title()
        centerTimeTitle.text = entryType.centerTimeTitle()
        leftTimeTitle.text = entryType.leftTimeTitle()
        leftTimeTitle.isHidden = entryType.showCenterTimeOnly()
        leftTimeLabel.isHidden = entryType.showCenterTimeOnly()
        rightTimeTitle.isHidden = entryType.showCenterTimeOnly()
        rightTimeLabel.isHidden = entryType.showCenterTimeOnly()

        //TOOD: add up the total times, based on the time entries

    }

    @IBAction func addButtonTapped(_ sender: Any) {
        isTrackingDuration = !isTrackingDuration
        let green = UIColor.init(red: 27.0/255.0,
                                 green: 210.0/255.0,
                                 blue: 141.0/255.0,
                                 alpha: 1)
        addButton.backgroundColor = isTrackingDuration ? .red : green
        let text = isTrackingDuration ? "Stop" : "Start"
        addButton.setTitle(text, for: .normal)

        //TODO: ask if you want to make a new entry for sure?
        // then make the new entry, reload the table view as appropriate
        // use timers to keep updating the table view cells each second
    }
}
