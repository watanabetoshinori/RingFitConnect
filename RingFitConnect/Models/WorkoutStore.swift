//
//  WorkoutStore.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import HealthKit

enum WorkOutStoreError: LocalizedError {

    case errorHealthDataUnavailable

    case errorQuantityTypeNotSupported

    case errorAuthorizationDenied

    case errorEmptyData

    var errorDescription: String? {
        switch self {
        case .errorHealthDataUnavailable:
            return "HealthKit is not available on this device."
        case .errorQuantityTypeNotSupported:
            return "The QuantityType required for this app is not supported."
        case .errorAuthorizationDenied:
            return "You are not allowed to access the HealthData that this app requires. Please grant permission from the Settings."
        case .errorEmptyData:
            return "There is no data to add."
        }
    }

}

class WorkoutStore {

    // MARK: - Requesting Authorization

    class func requestAuthorization(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.failure(WorkOutStoreError.errorHealthDataUnavailable))
            return
        }

        guard let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(.failure(WorkOutStoreError.errorQuantityTypeNotSupported))
            return
        }

        let typesToShare: Set<HKSampleType> = [
            activeEnergy,
            distanceWalkingRunning,
            .workoutType()
        ]

        let typesToRead: Set<HKObjectType> = [
            .workoutType()
        ]

        HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if HKHealthStore().authorizationStatus(for: activeEnergy) == .sharingAuthorized,
                HKHealthStore().authorizationStatus(for: distanceWalkingRunning) == .sharingAuthorized {
                completion(.success(true))

            } else {
                completion(.failure(WorkOutStoreError.errorAuthorizationDenied))
            }
        }
    }

    // MARK: - Managing Workout

    class func load(completion: @escaping (Result<[HKWorkout], Error>) -> Void) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .fitnessGaming)
        let sourcePredicate = HKQuery.predicateForObjects(from: .default())
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, sourcePredicate])

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let handler: (HKSampleQuery, [HKSample]?, Error?) -> Void = { (_, samples, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            let workouts = samples?.compactMap({ $0 as? HKWorkout }) ?? []
            completion(.success(workouts))
        }

        let query = HKSampleQuery(sampleType: .workoutType(),
                                  predicate: compound,
                                  limit: 0,
                                  sortDescriptors: [sortDescriptor],
                                  resultsHandler: handler)

        HKHealthStore().execute(query)
    }

    class func add(_ workouts: [HKWorkout], completion: @escaping (Result<Bool, Error>) -> Void) {
        if workouts.isEmpty {
            completion(.failure(WorkOutStoreError.errorEmptyData))
            return
        }

        HKHealthStore().save(workouts) { (success, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(success))
        }
    }

    class func delete(_ workouts: [HKWorkout], completion: @escaping (Result<Bool, Error>) -> Void) {
        HKHealthStore().delete(workouts) { (success, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(success))
        }
    }

}
