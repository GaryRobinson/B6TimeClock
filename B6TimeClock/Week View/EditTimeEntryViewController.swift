//
//  EditTimeEntryViewController.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

protocol EditTimeEntryDelegate: class {
    func updateEntries()
}

class EditTimeEntryViewController: UIViewController/*, UITextFieldDelegate*/ {

    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    weak var delegate: EditTimeEntryDelegate?
    var entry: TimeEntry?
    var toolbar = UIToolbar()

    //TODO: make my own picker view that allows seconds
    var startTimePicker = UIDatePicker()
    var durationTimePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let timeEntry = entry, let stopTime = timeEntry.stopTime else {
            print("oops, shouldn't get here")
            return
        }

        initTextFields(entry: timeEntry, stopTime: stopTime)

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                         action: #selector(EditTimeEntryViewController.saveTapped))
        saveButton.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton

        deleteButton.layer.cornerRadius = 5
    }

    func initTextFields(entry: TimeEntry, stopTime: Date) {
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        toolbar.setItems([cancelButton, flexButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true

        startTextField.text = entry.startTime.formattedTime()
        startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .dateAndTime
        startTimePicker.date = entry.startTime
        startTextField.inputView = startTimePicker
        startTextField.inputAccessoryView = toolbar

        let duration = stopTime.timeIntervalSince(entry.startTime)
        durationTextField.text = Date.formattedDuration(duration)
        durationTimePicker = UIDatePicker()
        durationTimePicker.datePickerMode = .countDownTimer
        durationTimePicker.countDownDuration = duration
        durationTextField.inputView = durationTimePicker
        durationTextField.inputAccessoryView = toolbar
    }

//    // MARK: Picker View
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return nil
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//    }

    @objc func cancelPicker(sender: UIBarButtonItem) {
        if startTextField.isEditing {
            startTextField.endEditing(true)
        }
        if durationTextField.isEditing {
            durationTextField.endEditing(true)
        }
    }

    @objc func donePicker(sender: UIBarButtonItem) {
        updateTextFields()
    }

    func updateTextFields() {
        if startTextField.isEditing {
            if let timeEntry = entry {
                timeEntry.startTime = startTimePicker.date
                startTextField.text = timeEntry.startTime.formattedTime()
            }
            startTextField.endEditing(true)
        }
        if durationTextField.isEditing {
            let duration = durationTimePicker.countDownDuration
            if let timeEntry = entry {
                timeEntry.stopTime = timeEntry.startTime.addingTimeInterval(duration)
                durationTextField.text = Date.formattedDuration(duration)
            }
            durationTextField.endEditing(true)
        }
    }

    // MARK: Text Field - not sure this section is needed

//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//    }
//
//    func textField(_ textField: UITextField,
//                   shouldChangeCharactersIn range: NSRange,
//                   replacementString string: String) -> Bool {
//
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return true
//    }

    // MARK: Button Actions

    @objc func saveTapped() {
        updateTextFields()
        TimeEntryController.shared.saveAllEntries()
        navigationController?.popViewController(animated: true)
        delegate?.updateEntries()
    }

    @IBAction func deleteTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete this entry?",
                                      message: "This action cannot be undone",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.doDelete()
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }

    func doDelete() {
        if let currentEntry = entry {
            TimeEntryController.shared.deleteEntry(currentEntry)
        }
        navigationController?.popViewController(animated: true)
        delegate?.updateEntries()
    }
}
