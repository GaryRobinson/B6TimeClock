//
//  ViewController.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit
import AudioToolbox

let sectionHeaderId = "SectionHeaderView"

class WeekViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    TimeEntryDelegate, EditTimeEntryDelegate, SectionHeaderDelegate {

    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var changeWeekButton: UIButton!
    @IBOutlet weak var daySegmentedControl: UISegmentedControl!
    @IBOutlet weak var weekTotalShiftLabel: UILabel!
    @IBOutlet weak var weekTotalBreakLabel: UILabel!
    @IBOutlet weak var weekTotalAfterCallLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var sections: [TimeEntryType] = TimeEntryType.getAll()
    var selectedEntry: TimeEntry?
    var currentStartOfWeek = Date().startOfWeek()
    //var selectedDay = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: sectionHeaderId, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        tableView.tableFooterView = UIView()

        TimeEntryController.shared.delegate = self

        changeWeekButton.layer.borderWidth = 1
        changeWeekButton.layer.borderColor = UIColor.white.cgColor
        changeWeekButton.layer.cornerRadius = 5

        updateCurrentWeek()

        NotificationCenter.default.addObserver(self, selector: #selector(WeekViewController.updateTimer),
                                               name: TimerNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentWeek()
        updateSummaryTimes()
        updateEntries()
    }

    func updateCurrentWeek() {
        currentStartOfWeek = TimeEntryController.shared.selectedDate.startOfWeek()
        let startString = currentStartOfWeek.formattedStartOfWeek()
        let endString = currentStartOfWeek.formattedEndOfWeek()
        weekLabel.text = "Sun, \(startString) to Sat, \(endString)"
        daySegmentedControl.selectedSegmentIndex = Calendar.current.component(
            .weekday, from: TimeEntryController.shared.selectedDate) - 1
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = sections[section]
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId)
            as? SectionHeaderView {
            headerView.configure(type: type, delegate: self)
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = sections[section]
        if type.isShowing() {
            let entries = TimeEntryController.shared.getFor(day: TimeEntryController.shared.selectedDate, type: type)
            return entries.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = sections[indexPath.section]
        let entries = TimeEntryController.shared.getFor(day: TimeEntryController.shared.selectedDate, type: type)
        let entry = entries[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TimeEntryCell", for: indexPath) as? TimeEntryCell {
            cell.configure(timeEntry: entry)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = sections[indexPath.section]
        let entries = TimeEntryController.shared.getFor(day: TimeEntryController.shared.selectedDate, type: type)
        let entry = entries[indexPath.row]
        selectedEntry = entry
        performSegue(withIdentifier: "editTimeEntry", sender: self)
    }

    func showingTypeChanged(_ type: TimeEntryType) {
        if let index = sections.index(of: type) {
            tableView.reloadSections(IndexSet.init(integer: index), with: .automatic)
        }
    }

    // MARK: - Actions

    @IBAction func dayControlChanged(_ sender: Any) {
        guard let newDay = Calendar.current.date(byAdding: .day,
                                                 value: daySegmentedControl.selectedSegmentIndex,
                                                 to: currentStartOfWeek) else {
                                                    return
        }
        TimeEntryController.shared.selectedDate = newDay
        tableView.reloadData()
    }

    @IBAction func settingsTapped(_ sender: Any) {
        let settingsVC = SettingsViewController.initFromStoryboard()
        present(settingsVC, animated: true, completion: nil)
    }

    @IBAction func changeWeekTapped(_ sender: Any) {
        performSegue(withIdentifier: "changeWeek", sender: self)
    }

    @IBAction func resetTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to reset?",
                                         message: "All data will be cleared and cannot be restored",
                                         preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            TimeEntryController.shared.clearAll()
            self.tableView.reloadData()
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }

    func startEntry(type: TimeEntryType) {
        updateSummaryTimes()
        if let section = sections.index(of: type) {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

    func stopEntry(type: TimeEntryType) {
        updateSummaryTimes()
        if let section = sections.index(of: type) {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? EditTimeEntryViewController {
            destVC.entry = selectedEntry
            destVC.delegate = self
        }
    }

    func updateEntries() {
        tableView.reloadData()
    }

    @objc func updateTimer(_ notification: Notification) {
        updateSummaryTimes()
    }

    func updateSummaryTimes() {
        let summary = TimeEntryController.shared.getWeekSummary()
        weekTotalShiftLabel.text = Date.formattedDuration(summary.shift)
        weekTotalBreakLabel.text = Date.formattedDuration(summary.breakRemaining)
        weekTotalAfterCallLabel.text = Date.formattedDuration(summary.afterCallRemaining)

        if summary.breakRemaining <= SettingType.BreakAlarm.getValue(),
            summary.breakRemaining + 1 > SettingType.BreakAlarm.getValue() {
            showBreakAlarm()
        }
        if summary.afterCallRemaining <= SettingType.AfterCallAlarm.getValue(),
            summary.afterCallRemaining + 1 > SettingType.AfterCallAlarm.getValue() {
            showAfterCallAlarm()
        }
    }

    func showBreakAlarm() {
        let alert = UIAlertController(title: "Break Alarm!",
                                      message: "\(SettingType.BreakAlarm.getValueString()) break remaining",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    func showAfterCallAlarm() {
        let alert = UIAlertController(title: "After Call Alarm!",
                                      message: "\(SettingType.BreakAlarm.getValueString()) after call remaining",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

}

