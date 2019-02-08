//
//  SettingsViewController.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    static func initFromStoryboard() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsNavC = storyboard.instantiateViewController(withIdentifier: "SettingsNavController")
            as? UINavigationController {
            return settingsNavC
        }
        return UINavigationController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingType.getAll().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = SettingType.getAll()[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell {
            cell.configure(type: type)
            return cell
        }
        return UITableViewCell()
    }

    // MARK: - Actions

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
