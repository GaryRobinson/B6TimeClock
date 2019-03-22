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

//TODO: make this modal, have a cancel on the left

class EditTimeEntryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    weak var delegate: EditTimeEntryDelegate?
    var initialEntry: TimeEntry?
    var currentEntry = TimeEntry()
    var toolbar = UIToolbar()

    var startTimePicker = UIDatePicker()
    var durationTimePicker = UIPickerView()
    var durationHours = 0
    var durationMinutes = 0
    var durationSeconds = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let timeEntry = initialEntry, let stopTime = timeEntry.stopTime else {
            print("oops, shouldn't get here")
            return
        }

        title = "Edit \(timeEntry.type.title())"

        currentEntry.type = timeEntry.type
        currentEntry.startTime = timeEntry.startTime
        currentEntry.stopTime = timeEntry.stopTime

        initTextFields(entry: timeEntry, stopTime: stopTime)

        deleteButton.layer.cornerRadius = 5
    }

    func initTextFields(entry: TimeEntry, stopTime: Date) {
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        toolbar.sizeToFit()
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        toolbar.setItems([/*cancelButton,*/ flexButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true

        startTextField.text = entry.startTime.formattedTime()
        startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .dateAndTime
        startTimePicker.date = entry.startTime
        startTextField.inputView = startTimePicker
        startTextField.inputAccessoryView = toolbar
        startTextField.delegate = self

        let duration = stopTime.timeIntervalSince(entry.startTime)
        let durationComponents = Date.durationComponents(duration)
        durationHours = durationComponents.hours
        durationMinutes = durationComponents.minutes
        durationSeconds = durationComponents.seconds

        durationTextField.text = Date.formattedDuration(duration)
        durationTimePicker = UIPickerView()
        durationTimePicker.delegate = self
        durationTextField.inputView = durationTimePicker
        durationTextField.inputAccessoryView = toolbar
        durationTextField.delegate = self
    }

    // MARK: Picker View

    enum DurationPicker: Int, CaseIterable {
        case Hours = 0
        case HoursLabel
        case Minutes
        case MinutesLabel
        case Seconds
        case SecondsLabel
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return DurationPicker.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let column = DurationPicker(rawValue: component) else { return 0 }
        switch column {
        case .HoursLabel, .MinutesLabel, .SecondsLabel:
            return 1
        case .Hours:
            return 24
        case .Minutes, .Seconds:
            return 60
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let column = DurationPicker(rawValue: component) else { return nil }
        switch column {
        case .Hours, .Minutes, .Seconds:
            return "\(row)"
        case .HoursLabel:
            return "hrs"
        case .MinutesLabel:
            return "mins"
        case .SecondsLabel:
            return "secs"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let column = DurationPicker(rawValue: component) else { return }
        switch column {
        case .Hours:
            durationHours = row
        case .Minutes:
            durationMinutes = row
        case .Seconds:
            durationSeconds = row
        default:
            break
        }
        updateTextFields(endEditing: false)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == durationTextField {
            durationTimePicker.selectRow(durationHours, inComponent: DurationPicker.Hours.rawValue, animated: false)
            durationTimePicker.selectRow(durationMinutes, inComponent: DurationPicker.Minutes.rawValue, animated: false)
            durationTimePicker.selectRow(durationSeconds, inComponent: DurationPicker.Seconds.rawValue, animated: false)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFields()
    }

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

    func updateTextFields(endEditing: Bool = true) {
        var duration: Double = Double(durationHours) * 60.0 * 60.0
        duration += Double(durationMinutes) * 60.0 + Double(durationSeconds)

        if startTextField.isEditing {
            currentEntry.startTime = startTimePicker.date
        }
        currentEntry.stopTime = currentEntry.startTime.addingTimeInterval(duration)

        startTextField.text = currentEntry.startTime.formattedTime()
        durationTextField.text = Date.formattedDuration(duration)

        if endEditing {
            startTextField.endEditing(true)
            durationTextField.endEditing(true)
        }
    }

    // MARK: Button Actions

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: Any) {
        updateTextFields()

        initialEntry?.startTime = currentEntry.startTime
        initialEntry?.stopTime = currentEntry.stopTime

        TimeEntryController.shared.saveAllEntries()
        dismiss(animated: true, completion: nil)
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
        if let entry = initialEntry {
            TimeEntryController.shared.deleteEntry(entry)
        }
        dismiss(animated: true, completion: nil)
        delegate?.updateEntries()
    }
}
