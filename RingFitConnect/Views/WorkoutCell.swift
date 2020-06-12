//
//  WorkoutCell.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import HealthKit

struct WorkoutCell: View {

    var day: String

    var weekday: String

    var duration: String

    var calorie: String

    var distance: String

    var minutesUnit: String {
        MeasurementFormatter().string(from: UnitDuration.minutes)
    }

    var calorieUnit: String {
        MeasurementFormatter().string(from: UnitEnergy.kilocalories)
    }

    var distanceUnit: String {
        if Locale.current.usesMetricSystem {
            return MeasurementFormatter().string(from: UnitLength.kilometers)
        } else {
            return MeasurementFormatter().string(from: UnitLength.miles)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(weekday)
                    .font(.title)
                    .fontWeight(.bold)
                    .scaleEffect(0.7)

            }
            .frame(width: 60)

            Divider()

            VStack(spacing: 2) {
                HStack(alignment: .top, spacing: 0) {
                    CaptionLabel(systemName: "stopwatch", label: "Time")
                        .frame(maxWidth: .infinity)
                    CaptionLabel(systemName: "flame.fill", label: "Calories")
                        .frame(maxWidth: .infinity)
                    CaptionLabel(systemName: "location.fill", label: "Distance")
                        .frame(maxWidth: .infinity)
                }
                HStack(alignment: .top, spacing: 0) {
                    QuantityLabel(quantity: duration, unit: minutesUnit)
                        .frame(maxWidth: .infinity)

                    QuantityLabel(quantity: calorie, unit: calorieUnit)
                        .frame(maxWidth: .infinity)

                    QuantityLabel(quantity: distance, unit: distanceUnit)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

}
