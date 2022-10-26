//
//  Run.swift
//  RunningCompanion
//
//  Created by Arno van Zyl on 2022/10/31.
//

import Foundation


struct Run: Identifiable {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var duration: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }
    
    var totalEnergyBurned: Double {
       let prancerciseCaloriesPerHour: Double = 450
       let hours: Double = duration / 3600
       let totalCalories = prancerciseCaloriesPerHour * hours
       return totalCalories
     }
}
