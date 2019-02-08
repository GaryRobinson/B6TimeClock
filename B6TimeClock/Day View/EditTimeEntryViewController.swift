//
//  EditTimeEntryViewController.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class EditTimeEntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    var entry: TimeEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let timeEntry = entry, let stopTime = timeEntry.stopTime else {
            print("oops, shouldn't get here")
            return
        }

        //TODO: use date/time pickers as the input views, add a toolbar & done button on them
        startTextField.text = timeEntry.startTime.formattedTime()
        durationTextField.text = Date.formattedDuration(stopTime.timeIntervalSince(timeEntry.startTime))

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                         action: #selector(EditTimeEntryViewController.saveTapped))
        saveButton.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton
    }

    @objc func saveTapped() {
        print("saveTapped")
        navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteTapped(_ sender: Any) {
        print("deleteTapped")
        navigationController?.popViewController(animated: true)
    }
}
