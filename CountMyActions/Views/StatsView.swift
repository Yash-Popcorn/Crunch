//
//  StatsView.swift
//  Crunch
//
//  Created by Yash Seth on 7/1/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct StatsView: View {
    
    var healthStore: HealthStore?
    @State var calBurnt = 0.0
    @State var steps = 0.0
    @State var restingBurnt = 0.0
    @State var theWeight = 0.0
    @State var theHeight = ""
    @EnvironmentObject var appState: AppState

    init() {
        healthStore = HealthStore()
    }
    
    func setData() {
        healthStore?.getStepCounts { (stepCount, error) in
            if let error = error {
                print("Error fetching steps: \(error.localizedDescription)")
                return
            }
            steps = stepCount ?? 0
            print("Today's step count is: \(stepCount ?? 0)")
        }

        healthStore?.getActiveEnergyBurned { (activeEnergyBurned, error) in
            if let error = error {
                print("Error fetching energy burned: \(error.localizedDescription)")
                return
            }
            calBurnt = activeEnergyBurned ?? 0
            print("Today's active energy burned is: \(activeEnergyBurned ?? 0) kcal")
        }
        
        healthStore?.getRestingCaloriesBurnt { (restingEnergyBurned, error) in
            if let error = error {
                print("Error fetching energy burned: \(error.localizedDescription)")
                return
            }
            restingBurnt = restingEnergyBurned ?? 0
            print("Today's resting energy burned is: \(restingEnergyBurned ?? 0) kcal")
        }
        
        healthStore?.getWeight { (weight, error) in
            if let error = error {
                print("Error fetching weight: \(error.localizedDescription)")
                return
            }
            
            // basic
            appState.weight = weight ?? 50
            theWeight = weight ?? 0
            
            print("Most recent weight is: \(weight ?? 0) kg")
        }

        healthStore?.getHeight { (height, error) in
            if let error = error {
                print("Error fetching height: \(error.localizedDescription)")
                return
            }
            
            let heightInMeters = height ?? 0
            let feetInAMeter = 3.28084
            let inchesInAFoot = 12.0

            let totalFeet = heightInMeters * feetInAMeter
            let feet = Int(totalFeet)
            let inches = (totalFeet - Double(feet)) * inchesInAFoot
            
            appState.height = inches + Double((feet * 12))
            theHeight = "\(feet)' \(Int(round(inches)))\""
            print("Most recent height is: \(height ?? 0) meters")
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Summary")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Physical Info")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width:350, height: 200)
                    .foregroundColor(Color("DarkGrey"))
                    .overlay(Color.black.opacity(0.35))
                    .padding(.trailing)
                    .overlay(
                        HStack() {
                            VStack(alignment: .leading, spacing: 40) {
                                VStack(alignment: .leading) {
                                    Text("Height")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.leading)
                                    Text(theHeight)
                                        .font(.title2)
                                        .foregroundColor(Color.orange)
                                }
                                VStack(alignment: .leading) {
                                    Text("Weight")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.leading)
                                    Text(String(format: "%.2f kg", theWeight))
                                        .font(.title2)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            .padding(.trailing, 70.0)
                            
                            VStack {
                                
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(width: 200 * 0.7, height: 200 * 0.7)
                                    .foregroundColor(Color("DarkGreen"))
                                    .overlay(
                                        VStack(spacing: -20) {
                                            Image(systemName: "dumbbell.fill")
                                                .resizable()
                                                .padding()
                                                .scaledToFit()
                                                .frame(width: 105, height: 75)
                                            Text("\(appState.workouts) workouts")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("Neon"))
                                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                                
                                        }
                                    )
                                    
                                
                            }
                                .padding(0.0)
                            
                        }
                        
                    )
                
                Text("Activity")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List{
                    HStack {
                        Image(systemName: "flame")
                            .resizable()
                            .foregroundColor(Color.orange)
                            .frame(width: 20, height: 25)
                        Text("Calories Burnt: \(String(format: "%.2f", calBurnt))")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color.orange)
                    }
                    .padding(.all, 4.0)
                    
                    HStack {
                        Image(systemName: "bed.double.fill")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.blue)
                        Text("Calories Burnt Resting: \(String(format: "%.2f", restingBurnt))")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.all, 4.0)
                    
                    HStack {
                        Image(systemName: "shoeprints.fill")
                            .resizable()
                            .frame(width: 22, height: 25)
                        Text("Total Steps: \(String(format: "%d", Int(steps)))")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .padding(.all, 4.0)
                }
                .listStyle(.insetGrouped)
                .preferredColorScheme(.dark)
            }
            .padding(.leading)
            .disabled(true)
            
            Spacer()
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black) // Background Color
            .onAppear {
                if let healthStore = healthStore {
                    healthStore.requestAuthorization { success in
                        if success {
                            print("Got Access")
                            setData()
                        }
                    }
                }
            }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView().environmentObject(AppState())
    }
}
