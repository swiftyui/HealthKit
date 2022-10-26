import Foundation
import HealthKit

class HealthStore: ObservableObject {
    
    var healthStore: HKHealthStore?
//    var session: HKWorkoutSession?
//    var builder: HKLiveWorkoutBuilder?
//
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func startNewRun(newRun: Run, completion: @escaping (Bool) -> ()) {
        guard let healthStore else { return }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .running
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: workoutConfiguration, device: .local())
        builder.beginCollection(withStart: newRun.startDate) { (sucecss, error) in
            guard sucecss else {
                completion(false)
                return
            }
        }
        
        guard let quantityType = HKQuantityType.quantityType(
          forIdentifier: .activeEnergyBurned) else {
          completion(false)
          return
        }
            
        let unit = HKUnit.kilocalorie()
        let totalEnergyBurned = newRun.totalEnergyBurned
        let quantity = HKQuantity(unit: unit, doubleValue: totalEnergyBurned)
        
        let sample = HKCumulativeQuantitySample(type: quantityType,
                                                quantity: quantity,
                                                start: newRun.startDate,
                                                end: newRun.endDate)
        
        DispatchQueue.main.async {
            //1. Add the sample to the workout builder
            builder.add([sample]) { (success, error) in
              guard success else {
                completion(false)
                return
              }
                  
              //2. Finish collection workout data and set the workout end date
              builder.endCollection(withEnd: newRun.endDate) { (success, error) in
                guard success else {
                  completion(false)
                  return
                }
                    
                //3. Create the workout with the samples added
                builder.finishWorkout { (_, error) in
                  let success = error == nil
                  completion(success)
                }
              }
            }
        }
    }
    
    
    func getGoals(completion: @escaping (Double, Double, Double) -> ()) {
        guard let healthStore else { return }
        
        let calendar = Calendar.autoupdatingCurrent
                
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )

        // This line is required to make the whole thing work
        dateComponents.calendar = calendar

        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            if error != nil {
                return
            }

            guard let summaries = summaries, summaries.count > 0 else { return }
            let energyUnit   = HKUnit.kilocalorie()
            let standUnit    = HKUnit.count()
            let exerciseUnit = HKUnit.second()
            
            for summary in summaries {
                let energy   = summary.activeEnergyBurned.doubleValue(for: energyUnit)
                let stand    = summary.appleStandHours.doubleValue(for: standUnit)
                let exercise = summary.appleExerciseTime.doubleValue(for: exerciseUnit)
                
                let energyGoal   = summary.activeEnergyBurnedGoal.doubleValue(for: energyUnit)
                let standGoal    = summary.appleStandHoursGoal.doubleValue(for: standUnit)
                let exerciseGoal = summary.appleExerciseTimeGoal.doubleValue(for: exerciseUnit)
                
                let energyProgress   = energyGoal == 0 ? 0 : ( energy / energyGoal ) * 100
                let standProgress    = standGoal == 0 ? 0 : ( stand / standGoal ) * 100
                let exerciseProgress = exerciseGoal == 0 ? 0 : ( exercise / exerciseGoal ) * 100
                completion(energyProgress, standProgress, exerciseProgress)
            }
        }
        healthStore.execute(query)
    }
    
    func getTimeSpent(completion: @escaping (Double) -> ()) {
        guard let type = HKSampleType.quantityType(forIdentifier: .appleExerciseTime) else { return }
        guard let healthStore else { return }
        
        let mondayOfTheSameWeek = Date().mondayOfTheSameWeek
        let predicate = HKQuery.predicateForSamples(withStart: mondayOfTheSameWeek, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
        var value: Double = 0.00
            if error != nil {
                print("Couldn't get time spent")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.minute())
            }
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    
    func getTotalCaloriesBurnt(completion: @escaping (Double) -> ()) {
        guard let type = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        guard let healthStore else { return }
        
        let mondayOfTheSameWeek = Date().mondayOfTheSameWeek
        let predicate = HKQuery.predicateForSamples(withStart: mondayOfTheSameWeek, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            var value: Double = 0.00
            if error != nil {
                print("Couldn't get calories burnt")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.kilocalorie())
            }
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    
    func getTotalDistanceRun(completion: @escaping (Double) -> ()) {
        guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("Something went wrong retriebing quantity type distanceWalkingRunning")
        }
        guard let healthStore else { return }
        
        let mondayOfTheSameWeek = Date().mondayOfTheSameWeek

        let predicate = HKQuery.predicateForSamples(withStart: mondayOfTheSameWeek, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            var value: Double = 0.00

            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.meterUnit(with: .kilo))
            }
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    
    
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        let readTypes = Set([HKObjectType.workoutType(),
                             HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                             HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                             HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                             HKObjectType.quantityType(forIdentifier: .heartRate)!,
                             HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                             HKObjectType.activitySummaryType()])
        
        let writeTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        guard let healthStore else { return completion(false)}

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
            completion(success)
        }
    }
    
}
