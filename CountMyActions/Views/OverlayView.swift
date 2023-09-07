/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's overlay view.
*/

import SwiftUI
import ConfettiSwiftUI

/// - Tag: OverlayView
struct OverlayView: View {

    let count: Float
    let calories: Float
    let flip: () -> Void
    @State var isHidden = false
    @State var rotationAngle: Double = 0
    @EnvironmentObject var appState: AppState
    @State var counter = 0
    @State var isCompleted = false    
    
    func getExerciseInfo(exerciseName: String) -> (workoutType: String, details: [String: Any])? {
        let workouts: [String: [String: [String: Any]]] = [
            "Yoga": Yoga.exercises,
            "Warmup": Warmup.exercises,
            "HardWorkout": HardWorkout.exercises
        ]

        for (workoutType, exercises) in workouts {
            if let exerciseDetails = exercises[exerciseName] {
                return (workoutType, exerciseDetails)
            }
        }
        
        return nil
    }

    
    var body: some View {
        
            VStack {
                if !isHidden {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Time")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(String(format: "%02d:%02d", Int(count) / 60, Int(count) % 60))
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(isCompleted ? .green : .yellow)
                        }
                        Spacer()
                        VStack {
                            Text("Calories")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(calories, specifier: "%2.2f")")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color("DarkGrey")).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 6))
                    HStack {
                        NavigationLink(destination: DashboardView()) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(Color("DarkRed"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 6)
                                    .overlay(
                                        Image(systemName: "door.left.hand.open")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 30)
                                            .foregroundColor(.white)
                                            .padding()
                                    )
                                    .onTapGesture {
                                        if (isCompleted) {
                                            appState.workouts += 1
                                        }
                                        appState.showPopover = false
                                    }
                        }
                        Spacer()
                    }
                    
                    
                }
                
                Spacer()
                
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 90, height: 90)
                        .foregroundColor(Color("DarkGrey"))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 6)
                    
                        .overlay(
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.easeInOut(duration: 0.5))
                        )
                        .onTapGesture {
                            withAnimation {
                                rotationAngle += 360
                                flip()
                            }
                        }
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 90, height: 90)
                        .foregroundColor(Color("DarkGrey"))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 6)
                        .overlay(
                            Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .scaleEffect(isHidden ? 0.9 : 1) // Add scaling animation
                                .animation(.easeInOut(duration: 0.3)) // Set animation duration and curve
                        )
                        .onTapGesture {
                            withAnimation {
                                isHidden.toggle()
                            }
                        }
                    
                    
                }
            }.padding()
            .confettiCannon(counter: $counter)
            .onChange(of: count) { newCountValue in
                print(newCountValue)
                if let timeString = appState.theTime as? Int {
                    let timeInSeconds = Float(timeString)
                    
                    if (timeInSeconds > 0){
                        let targetTimeInSeconds = timeInSeconds * 60
                        if Float(newCountValue) == targetTimeInSeconds {
                            isCompleted = true
                            counter += 1
                        }
                    } else {
                        print("Could not convert time string to float: \(timeString)")
                    }
                } else {
                    print("Could not get exercise details for: \(appState.currentExercise)")
                }
            }


        
    }
        
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(count: 3.0, calories: 3.449) { }
            .background(Color.red.opacity(0.4))
            .environmentObject(AppState())

    }
}
