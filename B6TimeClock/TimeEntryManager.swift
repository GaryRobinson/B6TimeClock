//
//  TimeEntryManager.swift
//  B6TimeClock
//
//  Created by Gary Robinson on 2/6/19.
//  Copyright © 2019 Gary Robinson. All rights reserved.
//

import UIKit

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
}
