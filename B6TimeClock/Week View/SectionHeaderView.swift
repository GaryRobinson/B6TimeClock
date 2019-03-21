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

protocol SectionHeaderDelegate: class {
    func showingTypeChanged(_ type: TimeEntryType)
}

class SectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var leftTimeTitle: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var centerTimeTitle: UILabel!
    @IBOutlet weak var centerTimeLabel: UILabel!
    @IBOutlet weak var rightTimeTitle: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var showButton: UIButton!

    var entryType = TimeEntryType.Shift
    var isTrackingDuration = false
    var isToday = false
    var isFuture = false
    weak var delegate: SectionHeaderDelegate?

    func configure(type: TimeEntryType, delegate: SectionHeaderDelegate) {
        entryType = type
        self.delegate = delegate

        isToday = Calendar.current.isDate(Date(), inSameDayAs: TimeEntryController.shared.selectedDate)
        isFuture = false
        if Calendar.current.startOfDay(for: TimeEntryController.shared.selectedDate) > Date() {
            isFuture = true
        }

        let dayOfWeek = TimeEntryController.shared.selectedDate.formattedDayOfWeek()
        sectionTitleLabel.text = "\(dayOfWeek) \(entryType.title())"
        centerTimeTitle.text = entryType.centerTimeTitle()
        leftTimeTitle.text = entryType.leftTimeTitle()
        leftTimeTitle.isHidden = entryType.showCenterTimeOnly()
        leftTimeLabel.isHidden = entryType.showCenterTimeOnly()
        rightTimeTitle.isHidden = entryType.showCenterTimeOnly()
        rightTimeLabel.isHidden = entryType.showCenterTimeOnly()

        isTrackingDuration = TimeEntryController.shared.isActive(type: type)

        updateShowButton()
        updateAddButton()
        updateTimes()

        NotificationCenter.default.addObserver(self, selector: #selector(SectionHeaderView.updateTimer),
                                               name: TimerNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        if isToday {
            isTrackingDuration = !isTrackingDuration
            updateAddButton()
            if isTrackingDuration {
                TimeEntryController.shared.addEntry(type: entryType)
            } else {
                TimeEntryController.shared.stopEntry(type: entryType)
            }
        } else {
            TimeEntryController.shared.addOldEntry(date: TimeEntryController.shared.selectedDate, type: entryType)
        }
    }

    func updateAddButton() {
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.white.cgColor
        addButton.layer.cornerRadius = 5

        addButton.backgroundColor = isTrackingDuration ? .red : green
        var buttonText = "Add"
        if isToday {
            buttonText = isTrackingDuration ? "Stop" : "Start"
        }
        addButton.setTitle(buttonText, for: .normal)
//        addButton.isHidden = isFuture
    }

    func updateShowButton() {
        showButton.layer.borderWidth = 1
        showButton.layer.borderColor = UIColor.white.cgColor
        showButton.layer.cornerRadius = 5

        if entryType.isShowing() {
            showButton.setTitle("Hide", for: .normal)
        } else {
            showButton.setTitle("Show", for: .normal)
        }

        let entries = TimeEntryController.shared.getFor(day: TimeEntryController.shared.selectedDate, type: entryType)
        showButton.isHidden = entries.count == 0 ? true : false
    }

    @IBAction func showButtonTapped(_ sender: Any) {
        showButton.isSelected = !showButton.isSelected
        entryType.saveShowing(!entryType.isShowing())
        updateShowButton()
        delegate?.showingTypeChanged(entryType)
    }

    func updateTimes() {
        let currentDate = TimeEntryController.shared.selectedDate
        let summary = TimeEntryController.shared.getDaySummary(date: currentDate)
        switch entryType {
        case .Shift:
            centerTimeLabel.text = Date.formattedDuration(summary.shift)
        case .Break:
            leftTimeLabel.text = Date.formattedDuration(summary.breakEarned)
            centerTimeLabel.text = Date.formattedDuration(summary.breakUsed)
            rightTimeLabel.text = Date.formattedDuration(summary.breakRemaining)
        case .AfterCall:
            leftTimeLabel.text = Date.formattedDuration(summary.afterCallEarned)
            centerTimeLabel.text = Date.formattedDuration(summary.afterCallUsed)
            rightTimeLabel.text = Date.formattedDuration(summary.afterCallRemaining)
        }
    }

    @objc func updateTimer(_ notification: Notification) {
        updateTimes()
    }
}
