//
//  TimeEntryType.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/8/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import Foundation

enum TimeEntryType: String {
    case Shift
    case Break
    case AfterCall

    public static func getAll() -> [TimeEntryType] {
        return [.Shift, .Break, .AfterCall]
    }

    public func title() -> String {
        switch self {
        case .Shift:
            return "SHIFT"
        case .Break:
            return "BREAK"
        case .AfterCall:
            return "AFTER CALL"
        }
    }

    public func leftTimeTitle() -> String {
        switch self {
        case .Shift:
            return ""
        case .Break:
            return "Earned"
        case .AfterCall:
            return "Available"
        }
    }

    public func centerTimeTitle() -> String {
        switch self {
        case .Shift:
            return "Worked"
        default:
            return "Used"
        }
    }

    public func showCenterTimeOnly() -> Bool {
        switch self {
        case .Shift:
            return true
        default:
            return false
        }
    }
}
