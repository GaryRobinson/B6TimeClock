//
//  ViewController.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

let sectionHeaderId = "SectionHeaderView"

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimeEntryDelegate {

    @IBOutlet weak var tableView: UITableView!

    var sections: [TimeEntryType] = [.Shift, .Break, .AfterCall]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: sectionHeaderId, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        tableView.tableFooterView = UIView()

        TimeEntryManager.shared.loadSavedEntries()
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
        let entries = TimeEntryManager.shared.getFor(day: Date(), type: type)
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = sections[indexPath.section]
        let entries = TimeEntryManager.shared.getFor(day: Date(), type: type)
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
        let entries = TimeEntryManager.shared.getFor(day: Date(), type: type)
        let entry = entries[indexPath.row]
        print("selected entry \(entry)")
    }

    // MARK: - Actions

    @IBAction func settingsTapped(_ sender: Any) {
        print("settings tapped")
    }

    @IBAction func resetTapped(_ sender: Any) {
        print("reset tapped")
    }

    func startEntry(type: TimeEntryType) {
        TimeEntryManager.shared.addEntry(type: type)
        TimeEntryManager.shared.saveAllEntries()
        if let section = sections.index(of: type) {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

    func stopEntry(type: TimeEntryType) {
        TimeEntryManager.shared.stopActiveEntry()
        if let section = sections.index(of: type) {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

}

