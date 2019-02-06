//
//  TimeEntry.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

class TimeEntry: NSObject {

    var id: Int
    var forDate: Date
    var type: TimeEntryType
    var startTime: Date
    var duration: Double

    override public init() {
        id = 0
        forDate = Date()
        type = .Shift
        startTime = Date()
        duration = 0
        super.init()
    }

    public init(id: Int, type: TimeEntryType) {
        self.id = id
        forDate = Date()
        self.type = type
        startTime = Date()
        duration = 0
        super.init()
    }

    public init(id: Int,
                forDate: Date,
                type: TimeEntryType,
                startTime: Date,
                duration: Double) {
        self.id = id
        self.forDate = forDate
        self.type = type
        self.startTime = startTime
        self.duration = duration
        super.init()
    }

    func toDictionary() -> [String: Any] {
        return ["id": id,
                "forDate": forDate,
                "type": type.rawValue,
                "startTime": startTime,
                "duration": duration]
    }

    static func fromDictionary(_ dict: [String: Any]) -> TimeEntry? {
        if let id = dict["id"] as? Int,
            let forDate = dict["forDate"] as? Date,
            let rawType = dict["type"] as? String,
            let type = TimeEntryType(rawValue: rawType),
            let startTime = dict["startTime"] as? Date,
            let duration = dict["duration"] as? Double {

            return TimeEntry.init(id: id,
                                  forDate: forDate,
                                  type: type,
                                  startTime: startTime,
                                  duration: duration)
        }
        return nil
    }

}

enum TimeEntryType: String {
    case Shift
    case Break
    case AfterCall

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
