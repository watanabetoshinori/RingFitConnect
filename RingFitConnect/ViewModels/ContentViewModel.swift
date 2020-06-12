//
//  ContentViewModel.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import HealthKit

class ContentViewModel: ObservableObject {

    @Published var workouts: [HKWorkout] = []

    @Published var error: Error?

    var isPresentingAlert: Binding<Bool> {
        Binding<Bool>(
            get: {
                return self.error != nil
            },
            set: { newValue in
                guard !newValue else { return }
                self.error = nil
            }
        )
    }

    // MARK: - Initializing View Model

    init() {

    }

    // MARK: - Request Authorization

    func initialize() {
        WorkoutStore.requestAuthorization { result in
            switch result {
            case .success:
                self.load()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }

    // MARK: - Managing Workout Data

    func load() {
        WorkoutStore.load { (result) in
            switch result {
                case .success(let workouts):
                    DispatchQueue.main.async {
                        self.workouts = workouts
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
            }
        }
    }

    func scan(_ images: [UIImage]) {
        let image = images.first!

        // Image to text
        TextRecognizer.recognizeText(from: image) { result in
            switch result {
            case .success(let texts):
                // Text to workout
                WorkoutLogManager.collectLogs(from: texts) { result in
                    switch result {
                    case .success(let workouts):
                        let filteredWorkouts = workouts.filter({ log in
                            // Exclude the workout if each value is zero.
                            if log.calorie == 0,
                                log.distance == 0,
                                log.duration == 0 {
                                return false
                            }

                            // Exclude the workout if the same workout has already been registered.
                            if let workout = self.workouts.first(where: { $0.startDate == log.startDate }) {
                                if workout.calorie == log.calorie,
                                    workout.distance == log.distance,
                                    workout.duration == log.duration {
                                    return false
                                }
                            }
                            return true
                        })

                        // Add workouts to HealthKit
                        WorkoutStore.add(filteredWorkouts) { result in
                            switch result {
                            case .success:
                                self.load()

                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self.error = error
                                }
                            }
                        }

                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.error = error
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }

    func removeWorkouts(indexSet: IndexSet) {
        let workoutsToDelete = indexSet.map { self.workouts[$0] }
        WorkoutStore.delete(workoutsToDelete) { result in
            switch result {
            case .success:
                self.load()

            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }

}
