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
    }

    func initTextFields(entry: TimeEntry, stopTime: Date) {
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        toolbar.sizeToFit()
        //TODO: cancel button too?
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        toolbar.setItems([flexButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true

        //TODO: initialize them
        startTextField.text = entry.startTime.formattedTime()
        startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
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

    //TODO: hook up the value changed event so the text updates that way
    @objc func donePicker(sender: UIBarButtonItem) {
        if startTextField.isEditing {
            //TODO: pull out the value
            if let timeEntry = entry {
                timeEntry.startTime = startTimePicker.date
                startTextField.text = timeEntry.startTime.formattedTime()
            }
            startTextField.endEditing(true)
        }
        if durationTextField.isEditing {
            //TODO: pull out the value
            let duration = durationTimePicker.countDownDuration
            if let timeEntry = entry {
                timeEntry.stopTime = timeEntry.startTime.addingTimeInterval(duration)
                durationTextField.text = Date.formattedDuration(duration)
            }
            durationTextField.endEditing(true)
        }
    }

    // MARK: Text Field - not sure this section is needed

    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    // MARK: Button Actions

    @objc func saveTapped() {
        print("saveTapped")
        TimeEntryController.shared.saveAllEntries()
        navigationController?.popViewController(animated: true)
        //TODO: get the main view to reload the cell w/ this entry
    }

    @IBAction func deleteTapped(_ sender: Any) {
        print("deleteTapped")
        navigationController?.popViewController(animated: true)
    }
}
