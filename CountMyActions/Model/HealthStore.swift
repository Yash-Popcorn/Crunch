//
//  HealthStore.swift
//  Crunch
//
//  Created by Yash Seth on 7/12/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import HealthKit

class HealthStore {
    var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    /**
        Write Active Energy Burned data to HealthKit
    */
    func addActiveEnergyBurned(_ activeEnergy: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        // Check if the quantity type is available
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            fatalError("Active Energy Burned Type is no longer available in HealthKit")
        }
        
        // Create the quantity for the energy
        let activeEnergyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: activeEnergy)
        
        // Create the quantity sample
        let activeEnergySample = HKQuantitySample(type: activeEnergyType, quantity: activeEnergyQuantity, start: date, end: date)
        
        // Save the quantity sample to the HealthKit Store
        healthStore?.save(activeEnergySample) { (success, error) in
            completion(success, error)
        }
    }

    /**
        Authorize the person before getting the information
     */
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let stepType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let caloriesType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let basalType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!
        let height = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let mass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

        // Data types to read
        let typesToRead: Set<HKObjectType> = [stepType, basalType, height, mass]
        
        // Data types to write
        let typesToWrite: Set<HKSampleType> = [caloriesType]

        healthStore?.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(success)
        }
    }

    
    /**
        Find about the number of steps they walked
     */
    func getStepCounts(completion: @escaping (Double?, Error?) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var resultCount: Double? = 0
            guard let result = result else {
                completion(nil, error)
                return
            }

            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }

            DispatchQueue.main.async {
                completion(resultCount, nil)
            }
        }

        healthStore?.execute(query)
    }

    /**
        Calories burnt
     */
    func getActiveEnergyBurned(completion: @escaping (Double?, Error?) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var resultCount: Double? = 0
            guard let result = result else {
                completion(nil, error)
                return
            }

            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.kilocalorie())
            }

            DispatchQueue.main.async {
                completion(resultCount, nil)
            }
        }

        healthStore?.execute(query)
    }
    
    /**
        Calories Resting Energy
     */
    func getRestingCaloriesBurnt(completion: @escaping (Double?, Error?) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var resultCount: Double? = 0
            guard let result = result else {
                completion(nil, error)
                return
            }

            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.kilocalorie())
            }

            DispatchQueue.main.async {
                completion(resultCount, nil)
            }
        }

        healthStore?.execute(query)
    }
    
    /**
        Get info for weight and height
     */
    func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                        completion(nil, error)
                        return
                }
                
                completion(mostRecentSample, nil)
            }
        }
        
        healthStore?.execute(query)
    }
    
    func getWeight(completion: @escaping (Double?, Error?) -> Void) {
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
        
        getMostRecentSample(for: weightSampleType) { (sample, error) in
            guard let sample = sample else {
                completion(nil, error)
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weightInKilograms, nil)
        }
    }

    func getHeight(completion: @escaping (Double?, Error?) -> Void) {
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        getMostRecentSample(for: heightSampleType) { (sample, error) in
            guard let sample = sample else {
                completion(nil, error)
                return
            }
            
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(heightInMeters, nil)
        }
    }

}
