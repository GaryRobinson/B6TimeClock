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

    public static func durationComponents(_ duration: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        var sign = 1.0
        if duration < 0 {
            sign = -1.0
        }
        let seconds = Int(duration + 0.5 * sign) % 60
        let minutes = (Int(duration + 0.5 * sign) / 60) % 60
        let hours = Int(duration + 0.5 * sign) / (60 * 60)
        return (hours: hours, minutes: minutes, seconds: seconds)
    }

    public static func formattedDuration(_ duration: TimeInterval, noHours: Bool = false) -> String {
        var result = ""
        var absDuration = duration
        if duration < 0 {
            absDuration *= -1
            result += "-"
        }
        let seconds = Int(absDuration + 0.5) % 60
        let secondsString = String(format: "%02d", seconds)
        let minutes = (Int(absDuration + 0.5) / 60) % 60
        let minutesString = String(format: "%02d", minutes)
        if noHours {
            result += "\(minutesString):\(secondsString)"
        } else {
            let hours = Int(absDuration + 0.5) / (60 * 60)
            let hoursString = String(format: "%02d", hours)
            result += "\(hoursString):\(minutesString):\(secondsString)"
        }
        return result
    }

    public func durationTo(date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        if let result = formatter.string(from: self, to: date) {
            return result
        }
        return "00:00:00"
    }

    public func startOfWeek() -> Date {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        if let start = Calendar.current.date(from: components) {
            return start
        }
        return self
    }

    public func formattedStartOfWeek() -> String {
        let formatter = Date.localDateFormatter()
        formatter.dateFormat = "LLL dd"
        let dateString = formatter.string(from: startOfWeek())
        return dateString
    }

    public func endOfWeek() -> Date {
        let start = startOfWeek()
        if let end = Calendar.current.date(byAdding: .day, value: 6, to: start) {
            return end
        }
        return self
    }

    public func formattedEndOfWeek() -> String {
        let formatter = Date.localDateFormatter()
        formatter.dateFormat = "LLL dd, yyyy"
        let dateString = formatter.string(from: endOfWeek())
        return dateString
    }

    public func formattedDayOfWeek() -> String {
        let formatter = Date.localDateFormatter()
        formatter.dateFormat = "EEEE"
        let dateString = formatter.string(from: self)
        return dateString
    }
}
