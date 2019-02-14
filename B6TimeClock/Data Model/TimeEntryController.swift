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

public let TimerNotification = NSNotification.Name("UpdateTimer")

class TimeEntryController: NSObject {
    public static let shared = TimeEntryController()

    deinit {
        timer?.invalidate()
    }

    private var nextId = 1
    private var allTimeEntries = [TimeEntry]()
    weak var delegate: TimeEntryDelegate?
    private var timer: Timer?
    private let savedEntriesKey = "SavedTimeEntries"

    public func loadSavedEntries() {
        if let dictionary = UserDefaults.standard.object(forKey: savedEntriesKey) as? [[String: Any]] {
            allTimeEntries = [TimeEntry]()
            for dict in dictionary {
                if let entry = TimeEntry.fromDictionary(dict) {
                    allTimeEntries.append(entry)
                }
            }
        }
    }

    public func saveAllEntries() {
        var dictionary = [[String: Any]]()
        for entry in allTimeEntries {
            dictionary.append(entry.toDictionary())
        }
        UserDefaults.standard.set(dictionary, forKey: savedEntriesKey)
        UserDefaults.standard.synchronize()
    }

    public func addEntry(type: TimeEntryType) {
        let id = nextId
        nextId += 1
        let newEntry = TimeEntry.init(id: id, type: type)
        allTimeEntries.append(newEntry)
        saveAllEntries()
        delegate?.startEntry(type: type)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.updateTimer()
        })
    }

    private func updateTimer() {
        NotificationCenter.default.post(name: TimerNotification, object: nil)
    }

    public func stopEntry(type: TimeEntryType) {
        timer?.invalidate()
        timer = nil
        if let active = allTimeEntries.filter({ $0.stopTime == nil && $0.type == type }).first {
            active.stopTime = Date()
        }
        saveAllEntries()
        delegate?.stopEntry(type: type)
    }

    public func deleteEntry(_ entry: TimeEntry) {
        if let index = allTimeEntries.index(of: entry) {
            allTimeEntries.remove(at: index)
            saveAllEntries()
        }
    }

    public func clearAll() {
        for type in TimeEntryType.getAll() {
            stopEntry(type: type)
        }
        allTimeEntries.removeAll()
        saveAllEntries()
    }

    public func isActive(type: TimeEntryType) -> Bool {
        if let _ = allTimeEntries.filter({ $0.type == type && $0.stopTime == nil }).first {
            return true
        }
        return false
    }

    public func getFor(day: Date, type: TimeEntryType) -> [TimeEntry] {
        let result = allTimeEntries.filter({ (entry) -> Bool in
            if entry.type == type, Calendar.current.isDate(entry.startTime, inSameDayAs: day) {
                return true
            }
            return false
        })
        return result.sorted(by: { (t1, t2) -> Bool in
            t1.startTime < t2.startTime
        })
    }

    public func getDurationWorked() -> TimeInterval {
        var duration: TimeInterval = 0
        let entries = TimeEntryController.shared.getFor(day: Date(), type: .Shift)
        for entry in entries {
            duration += entry.duration()
        }
        return duration
    }

    public func getBreakEarned() -> TimeInterval {
        let worked = getDurationWorked()
        let multiplier = SettingType.BreakEarnMultiplier.getValue()
        return worked * multiplier
    }

    public func getBreakUsed() -> TimeInterval {
        var duration: TimeInterval = 0
        let entries = TimeEntryController.shared.getFor(day: Date(), type: .Break)
        for entry in entries {
            duration += entry.duration()
        }
        return duration
    }

    public func getAvailableEarned() -> TimeInterval {
        let worked = getDurationWorked()
        let multiplier = SettingType.AfterCallEarnMultiplier.getValue()
        return worked * multiplier
    }

    public func getAfterCallUsed() -> TimeInterval {
        var duration: TimeInterval = 0
        let entries = TimeEntryController.shared.getFor(day: Date(), type: .AfterCall)
        for entry in entries {
            duration += entry.duration()
        }
        return duration
    }

}
