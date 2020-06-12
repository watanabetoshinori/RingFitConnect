//
//  Workout.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import HealthKit

struct WorkoutLog {

    var date: String = ""

    var calorie: String = ""

    var distance: String = ""

    var duration: String = ""

    var unitLength: UnitLength = .kilometers

    var hkworkout: HKWorkout {
        let durationInterval: TimeInterval = {
            let components = duration.components(separatedBy: ":")
            if components.count != 3 {
                return 0.0
            }

            let hours = Double(components[0]) ?? 0.0
            let minutes = Double(components[1]) ?? 0.0
            let seconds = Double(components[2]) ?? 0.0
            return hours * 3600 + minutes * 60 + seconds
        }()

        let start: Date = {
            let components = date.components(separatedBy: "/")
            if components.count != 2 {
                return Date()
            }

            let current = Date()
            let year = Calendar.current.component(.year, from: current)
            let month = Int(components[0])
            let day = Int(components[1])

            if let d = DateComponents(calendar: Calendar.current, year: year, month: month, day: day).date,
                Calendar.current.dateComponents([.day], from: current, to: d).day ?? 0 <= 0 {
                return d
            }

            return DateComponents(calendar: Calendar.current, year: year - 1, month: month, day: day).date ?? current
        }()

        let end = start.addingTimeInterval(durationInterval)

        let calorieQuantity = HKQuantity(unit: .kilocalorie(),
                                         doubleValue: Double(calorie) ?? 0.0)

        let distanceQuantity:HKQuantity = {
            if unitLength == .kilometers {
                return HKQuantity(unit: .meter(),
                                  doubleValue: (Double(distance) ?? 0.0) * 1000)
            } else {
                return  HKQuantity(unit: .mile(),
                                   doubleValue: Double(distance) ?? 0.0)
            }
        }()

        return HKWorkout(activityType: .fitnessGaming,
                         start: start,
                         end: end,
                         duration: durationInterval,
                         totalEnergyBurned: calorieQuantity,
                         totalDistance: distanceQuantity,
                         metadata: nil)
    }

}
