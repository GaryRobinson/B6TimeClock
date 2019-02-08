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
    var type: TimeEntryType
    var startTime: Date
    var stopTime: Date?

    override public init() {
        id = 0
        type = .Shift
        startTime = Date()
        stopTime = nil
        super.init()
    }

    public init(id: Int, type: TimeEntryType) {
        self.id = id
        self.type = type
        startTime = Date()
        stopTime = nil
        super.init()
    }

    public init(id: Int,
                type: TimeEntryType,
                startTime: Date,
                stopTime: Date?) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.stopTime = stopTime
        super.init()
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = ["id": id,
                                   "type": type.rawValue,
                                   "startTime": startTime]
        if let stop = stopTime {
            dict["stopTime"] = stop
        }
        return dict
    }

    static func fromDictionary(_ dict: [String: Any]) -> TimeEntry? {
        if let id = dict["id"] as? Int,
            let rawType = dict["type"] as? String,
            let type = TimeEntryType(rawValue: rawType),
            let startTime = dict["startTime"] as? Date {

            var stopTime: Date?
            if let stop = dict["stopTime"] as? Date {
                stopTime = stop
            }
            return TimeEntry.init(id: id,
                                  type: type,
                                  startTime: startTime,
                                  stopTime: stopTime)
        }
        return nil
    }

    func durationString() -> String {
        if let stop = stopTime {
            return Date.formattedDuration(stop.timeIntervalSince(startTime))
        } else {
            return Date.formattedDuration(Date().timeIntervalSince(startTime))
        }
    }

    func duration() -> TimeInterval {
        if let stop = stopTime {
            return stop.timeIntervalSince(startTime)
        } else {
            return Date().timeIntervalSince(startTime)
        }
    }

}
