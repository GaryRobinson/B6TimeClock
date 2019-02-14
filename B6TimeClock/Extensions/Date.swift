//
//  Date.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import Foundation

extension Date {

    public static func localDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }

    public func formattedTime() -> String {
        let formatter = Date.localDateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yy, h:mm:ss a"
        let dateString = formatter.string(from: self)
        return dateString
    }

    public static func formattedDuration(_ duration: TimeInterval, noHours: Bool = false) -> String {
        let seconds = Int(duration) % 60
        let secondsString = String(format: "%02d", seconds)
        let minutes = (Int(duration) / 60) % 60
        let minutesString = String(format: "%02d", minutes)
        if noHours {
            return "\(minutesString):\(secondsString)"
        } else {
            let hours = Int(duration) / (60 * 60)
            let hoursString = String(format: "%02d", hours)
            return "\(hoursString):\(minutesString):\(secondsString)"
        }
    }

    public func durationTo(date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        if let result = formatter.string(from: self, to: date) {
            return result
        }
        return "00:00:00"
    }
}
