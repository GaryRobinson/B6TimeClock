//
//  ChangeWeekViewController.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/27/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class ChangeWeekViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.maximumDate = Date()
        datePicker.date = TimeEntryController.shared.selectedDate

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                         action: #selector(ChangeWeekViewController.saveTapped))
        saveButton.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton
    }

    @objc func saveTapped() {
        TimeEntryController.shared.selectedDate = datePicker.date
        navigationController?.popViewController(animated: true)
    }

}
