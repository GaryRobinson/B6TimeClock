//
//  SectionHeaderCell.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

let green = UIColor.init(red: 27.0/255.0,
                         green: 210.0/255.0,
                         blue: 141.0/255.0,
                         alpha: 1)

class SectionHeaderView: UITableViewHeaderFooterView {

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
        entryType = type

        sectionTitleLabel.text = entryType.title()
        centerTimeTitle.text = entryType.centerTimeTitle()
        leftTimeTitle.text = entryType.leftTimeTitle()
        leftTimeTitle.isHidden = entryType.showCenterTimeOnly()
        leftTimeLabel.isHidden = entryType.showCenterTimeOnly()
        rightTimeTitle.isHidden = entryType.showCenterTimeOnly()
        rightTimeLabel.isHidden = entryType.showCenterTimeOnly()

        isTrackingDuration = TimeEntryController.shared.isActive(type: type)

        updateAddButton()
        updateTimes()

        NotificationCenter.default.addObserver(self, selector: #selector(SectionHeaderView.updateTimer),
                                               name: TimerNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        //TODO: ask if you want to make a new entry for sure?
        isTrackingDuration = !isTrackingDuration
        updateAddButton()
        if isTrackingDuration {
            TimeEntryController.shared.addEntry(type: entryType)
        } else {
            TimeEntryController.shared.stopEntry(type: entryType)
        }
    }

    func updateAddButton() {
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.white.cgColor
        addButton.layer.cornerRadius = 5

        addButton.backgroundColor = isTrackingDuration ? .red : green
        let text = isTrackingDuration ? "Stop" : "Start"
        addButton.setTitle(text, for: .normal)

        addButton.isHidden = !Calendar.current.isDate(Date(), inSameDayAs: TimeEntryController.shared.selectedDate)
    }

    func updateTimes() {
        let currentDate = TimeEntryController.shared.selectedDate
        switch entryType {
        case .Shift:
            let worked = TimeEntryController.shared.getDurationWorked(date: currentDate)
            centerTimeLabel.text = Date.formattedDuration(worked)
        case .Break:
            let earned = TimeEntryController.shared.getBreakEarned(date: currentDate)
            leftTimeLabel.text = Date.formattedDuration(earned)
            let used = TimeEntryController.shared.getBreakUsed(date: currentDate)
            centerTimeLabel.text = Date.formattedDuration(used)
            let remaining = earned - used
            if remaining < 0 {
                rightTimeLabel.text = "-\(Date.formattedDuration(-1 * remaining))"
            } else {
                rightTimeLabel.text = Date.formattedDuration(remaining)
            }
            break
        case .AfterCall:
            let available = TimeEntryController.shared.getAvailableEarned(date: currentDate)
            leftTimeLabel.text = Date.formattedDuration(available)
            let used = TimeEntryController.shared.getAfterCallUsed(date: currentDate)
            centerTimeLabel.text = Date.formattedDuration(used)
            let remaining = available - used
            if remaining < 0 {
                rightTimeLabel.text = "-\(Date.formattedDuration(-1 * remaining))"
            } else {
                rightTimeLabel.text = Date.formattedDuration(remaining)
            }
            break
        }
    }

    @objc func updateTimer(_ notification: Notification) {
        updateTimes()
    }
}
