//
//  AppModel.swift
//  Crunch
//
//  Created by Yash Seth on 7/1/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

/**
 Global State
 */
class AppState: ObservableObject {
    @Published var showPopover: Bool = false
    @Published var calories: Int = 0
    @Published var workouts: Int = 0 {
        didSet {
            UserDefaults.standard.set(workouts, forKey: "workouts")
        }
    }
    @Published var currentExercise: String = ""
    // basic average metrics
    @Published var weight = 50.0
    @Published var height = 67.0
    @Published var calorieIncrement: Float = 0
    @Published var theTime = 0
    
    init() {
        self.workouts = UserDefaults.standard.integer(forKey: "workouts")
    }
    
    func toggle() {
        showPopover.toggle()
    }
    
    func addCalories(c: Int) {
        calories += c
    }
    
    func changeExercise(e: String) {
        currentExercise = e
    }
    
}
