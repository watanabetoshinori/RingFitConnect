//
//  HKWorkout+Extension.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import HealthKit

extension HKWorkout {

    var calorie: Double {
        totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0.0
    }

    var distance: Double {
        totalDistance?.doubleValue(for: .meter()) ?? 0.0
    }

    var day: String {
        String(Calendar.current.component(.day, from: startDate))
    }

    var weekday: String {
        let component = Calendar.current.component(.weekday, from: startDate)
        let formatter = DateFormatter()
        return formatter.veryShortWeekdaySymbols[component - 1]
    }

    var formattedDuration: String {
        String(format: "%d", Int(duration / 60))
    }

    var formattedCalorie: String {
        String(format: "%d", Int(calorie))
    }

    var formattedDistance: String {
        if Locale.current.usesMetricSystem {
            return String(format: "%0.1f", distance / 1000)
        } else {
            let miles = Measurement(value: distance, unit: UnitLength.meters).converted(to: .miles).value
            return String(format: "%0.1f", miles)
        }
    }

}
