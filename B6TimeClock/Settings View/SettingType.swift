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
    case BreakAlarmWeek
    case BreakEarnMultiplier
    case AfterCallAlarm
    case AfterCallAlarmWeek
    case AfterCallEarnMultiplier

    static func getForSection(_ section: Int) -> [SettingType] {
        if section == 0 {
            return [.BreakAlarm, .BreakAlarmWeek, .BreakEarnMultiplier]
        } else {
            return [.AfterCallAlarm, .AfterCallAlarmWeek, .AfterCallEarnMultiplier]
        }
    }

    func title() -> String {
        switch self {
        case .BreakAlarm:
            return "Daily Break Alarm"
        case .BreakAlarmWeek:
            return "Weekly Break Alarm"
        case .BreakEarnMultiplier:
            return "Break Earn Multiplier"
        case .AfterCallAlarm:
            return "Daily After Call Alarm"
        case .AfterCallAlarmWeek:
            return "Weekly After Call Alarm"
        case .AfterCallEarnMultiplier:
            return "After Call Earn Multiplier"
        }
    }

    func isAlarm() -> Bool {
        switch self {
        case .BreakAlarm, .BreakAlarmWeek, .AfterCallAlarm, .AfterCallAlarmWeek:
            return true
        default:
            return false
        }
    }

    func defaultValue() -> Double {
        switch self {
        case .BreakAlarm:
            return 120
        case .BreakAlarmWeek:
            return 120
        case .BreakEarnMultiplier:
            return 0.075
        case .AfterCallAlarm:
            return 120
        case .AfterCallAlarmWeek:
            return 120
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
        case .BreakAlarm, .BreakAlarmWeek, .AfterCallAlarm, .AfterCallAlarmWeek:
            return Date.formattedDuration(value, noHours: true)
        default:
            return String(value)
        }
    }
}
