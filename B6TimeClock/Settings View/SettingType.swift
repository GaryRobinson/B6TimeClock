//
//  SettingType.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import Foundation

enum SettingType: String {
    case BreakAlarm
    case AfterCallAlarm
    case BreakEarnMultiplier
    case AfterCallEarnMultiplier

    static func getAll() -> [SettingType] {
        return [.BreakAlarm,
                .AfterCallAlarm,
                .BreakEarnMultiplier,
                .AfterCallEarnMultiplier]
    }

    func title() -> String {
        switch self {
        case .BreakAlarm:
            return "Break Alarm"
        case .AfterCallAlarm:
            return "After Call Alarm"
        case .BreakEarnMultiplier:
            return "Break Earn Multiplier"
        case .AfterCallEarnMultiplier:
            return "After Call Earn Multiplier"
        }
    }

    func defaultValue() -> Double {
        switch self {
        case .BreakAlarm:
            return 120
        case .AfterCallAlarm:
            return 120
        case .BreakEarnMultiplier:
            return 0.075
        case .AfterCallEarnMultiplier:
            return 0.033334
        }
    }

    func save(value: Double) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }

    func getValue() -> Double {
        if let value = UserDefaults.standard.value(forKey: self.rawValue) as? Double {
            return value
        }
        return self.defaultValue()
    }

    func getValueString() -> String {
        let value = getValue()
        switch self {
        case .BreakAlarm, .AfterCallAlarm:
            return Date.formattedDuration(value, noHours: true)
        default:
            return String(value)
        }
    }
}
