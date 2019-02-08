//
//  SettingsCell.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    func configure(type: SettingType) {
        settingLabel.text = type.title()
        textField.text = type.getValueString()
    }
}
