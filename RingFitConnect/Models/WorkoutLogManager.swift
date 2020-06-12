//
//  LogManager.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import HealthKit

enum WorkoutLogManagerError: LocalizedError {

    case errorCollectLogFailed

    var errorDescription: String? {
        switch self {
        case .errorCollectLogFailed:
            return "Failed to collect the log information. Take a picture so that the log screen fits into the camera."
        }
    }

}

class WorkoutLogManager {

    class func collectLogs(from texts: [String], completion: @escaping (Result<[HKWorkout], Error>) -> Void) {
        // 10/18, 06/09, 10/20 (), 03/15 (E)
        let datePattern = #"(?<value>(1[0-2]|[1-9])\/(3[0-1]|[1-2][0-9]|0[1-9]))[ ]?"#
        // 0:28:48, 0:00:01
        let durationPattern = #"(?<value>[0-9]+:[0-5][0-9]:[0-5][0-9])"#
        // 74.25 Cal, 41.00 Cal, 127.10kcal, 150.00kcal,
        let caloriePattern = #"(?<value>([0-9]*[.])?[0-9]+)[ ]?(kcal|Cal)"#
        // 1.85km, 0.55km
        let distancePattern1 = #"(?<value>([0-9]*[.])?[0-9]+)[ ]?km"#
        // 1.20 mi., 0.55mi.
        let distancePattern2 = #"(?<value>([0-9]*[.])?[0-9]+)[ ]?mi."#

        var logs = [WorkoutLog]()
        var workoutLog: WorkoutLog?

        // If the data is correct, the string is expected to be aligned as follows:
        // Date, Duration, Calorie, Distance, Date, ...

        texts.forEach { text in
            if let result = regex(pattern: datePattern, string: text) {
                workoutLog = WorkoutLog()
                workoutLog?.date = result
            } else if let result = regex(pattern: durationPattern, string: text) {
                workoutLog?.duration = result
            } else if let result = regex(pattern: caloriePattern, string: text) {
                workoutLog?.calorie = result
            } else if let result = regex(pattern: distancePattern1, string: text) {
                workoutLog?.distance = result
            } else if let result = regex(pattern: distancePattern2, string: text) {
                workoutLog?.distance = result
                workoutLog?.unitLength = .miles
            }

            if let completedWorkoutLog = workoutLog,
                completedWorkoutLog.duration.isEmpty == false,
                completedWorkoutLog.calorie.isEmpty == false,
                completedWorkoutLog.distance.isEmpty == false {

                logs.append(completedWorkoutLog)
                workoutLog = nil
            }
        }

        if logs.isEmpty {
            completion(.failure(WorkoutLogManagerError.errorCollectLogFailed))
            return
        }

        print(logs)

        // Sample output of logs:
        // 10/18, 0:28:48, 127.10, 2.10
        // 10/20, 0:33:44, 136.50, 1.90
        // 10/21, 0:36:39, 150.00, 2.85

        completion(.success(logs.compactMap { $0.hkworkout } ))
    }

    private class func regex(pattern: String, string: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern)

        let nsRange = NSRange(string.startIndex..<string.endIndex, in: string)
        if let match = regex.firstMatch(in: string, options: [], range: nsRange) {
            let nsrange = match.range(withName: "value")
            if nsrange.location != NSNotFound, let range = Range(nsrange, in: string) {
                return "\(string[range])"
            }
        }

        return nil
    }

}

