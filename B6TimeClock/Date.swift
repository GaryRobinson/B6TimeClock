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
        formatter.dateFormat = "h:mm:ss a"
        let dateString = formatter.string(from: self)
        return dateString
    }
}
