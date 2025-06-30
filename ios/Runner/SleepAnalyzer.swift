//
//  SleepAnalyzer.swift
//  Runner
//
//  Created by ABHI on 23/06/25.
//

import Foundation
import CoreMotion

class SleepAnalyzer {
    static let motionManager = CMMotionActivityManager()
    static var LSSleepStart = ""
    static var LSSleepStop = ""
    static var LSSleepCheck = ""
    static var LSSleepInterval = 3600
    
    static func setDataFromSettings(settingsData: [String: Any]) {
        LSSleepStart = settingsData["lSStartTime"] as? String ?? ""
        LSSleepStop = settingsData["lSHardStopTime"] as? String ?? ""
        LSSleepCheck = settingsData["lSEndTime"] as? String ?? ""
        LSSleepInterval = settingsData["sleepInterval"] as? Int ?? 3600
    }
    static func fetchSleepData(for givenDate: Date, completion: @escaping ([[String: Any]]) -> ()) {
        var sleepData: [(date: Date, startTime: String, endTime: String, duration: TimeInterval)] = []
        var sleepArray = [[String:Any]]()
        let today = Date()
        let calendar = Calendar.current
        //let previousDay = calendar.date(byAdding: .day, value: -1, to: today)!
        let endSleepDate = givenDate
        let startSleepDate = calendar.date(byAdding: .day, value: -1, to: givenDate)!
        
        guard let nightStartTime = parseTimeString(timeString: LSSleepStart),
              let nightEndTime = parseTimeString(timeString: LSSleepStop),
              let nightCheckTime = parseTimeString(timeString: LSSleepCheck) else {
            print("Error parsing sleep start/stop time")
            completion([])
            return
        }
        
        guard let nightStartPreviousDay = calendar.date(bySettingHour: nightStartTime.Hour, minute: nightStartTime.Min, second: 0, of: startSleepDate),
              let nightEndPreviousDay = calendar.date(bySettingHour: nightEndTime.Hour, minute: nightEndTime.Min, second: 0, of: endSleepDate),
              let sleepCheckTime = calendar.date(bySettingHour: nightCheckTime.Hour, minute: nightCheckTime.Min, second: 0, of: givenDate) else {
            print("Error setting sleep date ranges")
            completion([])
            return
        }
        
        let dateRanges = [(start: nightStartPreviousDay, end: nightEndPreviousDay)]
        let dispatchGroup = DispatchGroup()
        
        for range in dateRanges {
            dispatchGroup.enter()
            
            motionManager.queryActivityStarting(from: range.start, to: range.end, to: OperationQueue.main) { (activities, error) in
                guard error == nil else {
                    print("Error fetching motion activities: \(error?.localizedDescription ?? "")")
                    dispatchGroup.leave()
                    return
                }
                
                var sleepPeriods: [(startTime: Date, endTime: Date)] = []
                
                if activities?.count ?? 0 > 2 {
                    for i in 1..<(activities?.count ?? 1) {
                        let previousActivity = activities?[i - 1]
                        let currentActivity = activities?[i]
                        
                        guard let prevStart = previousActivity?.startDate,
                              let currStart = currentActivity?.startDate else { continue }
                        
                        // If an activity is found between sleepCheckTime and nightEndPreviousDay, stop further processing
                        if currStart >= sleepCheckTime && currStart <= nightEndPreviousDay {
                            //print("Activity found between sleepCheckTime and nightEndPreviousDay at \(currStart)")
                            sleepPeriods.append((startTime: prevStart, endTime: currStart))
                            break // Stop further processing
                        }
                        
                        // Check the gap duration
                        let gapDuration = currStart.timeIntervalSince(prevStart)
                        
                        // Consider as sleep if it falls within sleep range and gap duration exceeds 1 hour
                        //print("Sleep interval is: \(gapDuration) from \(range.start) to \(range.end)")
                        
                        if gapDuration > Double(LSSleepInterval),
                           prevStart >= range.start && currStart <= range.end {
                            sleepPeriods.append((startTime: prevStart, endTime: currStart))
                        }
                    }
                    
                    // Store the sleep data for each period
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = .current
                    
                    var sleepValue = 0.0
                    for sleepPeriod in sleepPeriods {
                        let duration = sleepPeriod.endTime.timeIntervalSince(sleepPeriod.startTime)
                        if duration > Double(LSSleepInterval) {
                            sleepData.append((date: calendar.startOfDay(for: range.start), startTime: dateFormatter.string(from: sleepPeriod.startTime), endTime: dateFormatter.string(from: sleepPeriod.endTime), duration: duration))
                            sleepValue += Double(duration)
                        }
                    }
                    
                    sleepArray.append([
                        "field": "sleepCount",
                        "value": String(format: "%.0f", sleepValue),
                        "startTime": sleepData.first?.startTime ?? "",
                        "endTime": sleepData.last?.endTime ?? "",
                        "source": "Motion Fitness"
                    ])
                    dispatchGroup.leave()
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = .current
                    
                    sleepArray.append([
                        "field": "sleepCount",
                        "value": range.end.timeIntervalSince(range.start),
                        "startTime": dateFormatter.string(from: range.start),
                        "endTime": dateFormatter.string(from: range.end),
                        "source": "Motion Fitness"
                    ])
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(sleepArray)
        }
    }
    static func parseTimeString(timeString: String) -> HourMinObject? {
        let timeComponents = timeString.split(separator: ":")
        if timeComponents.count == 2, let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]) {
            let hourMinObject = HourMinObject()
            hourMinObject.Hour = hour
            hourMinObject.Min = minute
            return hourMinObject
        } else {
            return nil
        }
    }
}
class HourMinObject {
    var Hour = Int()
    var Min = Int()
}
