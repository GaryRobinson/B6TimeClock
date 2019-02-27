//
//  SettingsCell.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var settingType = SettingType.BreakAlarm
    var pickerView = UIPickerView()
    var toolbar = UIToolbar()
    var currentMinutes = 0
    var currentSeconds = 0

    func configure(type: SettingType) {
        settingType = type
        settingLabel.text = settingType.title()
        textField.text = settingType.getValueString()

        switch settingType {
        case .BreakAlarm, .AfterCallAlarm:
            initAlarmPickerView()
            textField.inputView = pickerView
            currentMinutes = Int(settingType.getValue()) / 60
            currentSeconds = Int(settingType.getValue()) % 60
            pickerView.selectRow(currentMinutes, inComponent: 0, animated: true)
            pickerView.selectRow(currentSeconds, inComponent: 1, animated: true)
        default:
            textField.inputView = nil
            textField.keyboardType = .decimalPad
        }

        initToolbar()
        textField.inputAccessoryView = toolbar
        textField.delegate = self
    }

    func initAlarmPickerView() {
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
    }

    func initToolbar() {
        toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        toolbar.sizeToFit()
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        toolbar.setItems([flexButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
    }

    // MARK: - Picker View

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row) minutes"
        } else {
            return "\(row) seconds"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currentMinutes = row
        } else {
            currentSeconds = row
        }
        settingType.save(value: 60.0 * (Double)(currentMinutes) + (Double)(currentSeconds))
        textField.text = settingType.getValueString()
    }

    // MARK: - Text field

    @objc func donePicker(sender: UIBarButtonItem) {
        endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch settingType {
        case .BreakAlarm, .AfterCallAlarm:
            pickerView.selectRow(currentMinutes, inComponent: 0, animated: true)
            pickerView.selectRow(currentSeconds, inComponent: 1, animated: true)
        default:
            break
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch settingType {
        case .BreakAlarm, .AfterCallAlarm:
            settingType.save(value: 60.0 * (Double)(currentMinutes) + (Double)(currentSeconds))
        default:
            if let text = textField.text, let double = Double(text) {
                settingType.save(value: double)
            }
        }
    }

}
