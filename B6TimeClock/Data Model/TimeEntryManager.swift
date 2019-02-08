//
//  TimeEntryManager.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

protocol TimeEntryDelegate: class {
    func startEntry(type: TimeEntryType)
    func stopEntry(type: TimeEntryType)
}

class TimeEntryManager: NSObject {
    public static let shared = TimeEntryManager()

    var nextId = 1
    var allTimeEntries = [TimeEntry]()

    func loadSavedEntries() {
        if let dictionary = UserDefaults.standard.object(forKey: "SavedTimeEntries") as? [[String: Any]] {
            allTimeEntries = [TimeEntry]()
            for dict in dictionary {
                if let entry = TimeEntry.fromDictionary(dict) {
                    allTimeEntries.append(entry)
                }
            }
        }
    }

    func saveAllEntries() {
        var dictionary = [[String: Any]]()
        for entry in allTimeEntries {
            dictionary.append(entry.toDictionary())
        }
        UserDefaults.standard.set(dictionary, forKey: "SavedTimeEntries")
        UserDefaults.standard.synchronize()
    }

    func addEntry(type: TimeEntryType) {
        let id = nextId
        nextId += 1
        let newEntry = TimeEntry.init(id: id, type: type)
        allTimeEntries.append(newEntry)
    }

    public func getFor(day: Date, type: TimeEntryType) -> [TimeEntry] {
        let result = allTimeEntries.filter({ (entry) -> Bool in
            if entry.type == type {
                //TODO: also test for the data being on the same day
                return true
            }
            return false
        })
        return result.sorted(by: { (t1, t2) -> Bool in
            t1.startTime < t2.startTime
        })
    }

    public func getDurationWorked() -> String {
        var duration: TimeInterval = 0
        let entries = TimeEntryManager.shared.getFor(day: Date(), type: .Shift)
        for entry in entries {
            duration += entry.duration()
        }
        return Date.formattedDuration(duration)
    }

    public func stopActiveEntry() {
        if let active = allTimeEntries.filter({ $0.stopTime == nil }).first {
            active.stopTime = Date()
        }
        saveAllEntries()
    }

    public func isActive(type: TimeEntryType) -> Bool {
        if let _ = allTimeEntries.filter({ $0.type == type && $0.stopTime == nil }).first {
            return true
        }
        return false
    }

}
