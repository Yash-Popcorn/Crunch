import SwiftUI

struct WarmUpCard: View {
    var image: String = "Sit Ups"
    var workout_name: String = "Planks"
    var time: String = "10 min"
    var calories: String = "10 cals"
    @EnvironmentObject var appState: AppState
    @State private var isModalPresented = false
    @State private var textFieldValue = ""

    var body: some View {
        VStack(alignment: .leading) {
            Image(image)
                .resizable()
                .frame(width: 200, height: 150)
                .clipShape(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                )
            cardText.padding(.horizontal, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("DarkGrey"))
                .blur(radius: 0.3)
        )
        .onTapGesture {
            isModalPresented = true
            //appState.toggle()
            appState.changeExercise(e: workout_name)
        }
        .sheet(isPresented: $isModalPresented) {
            ModalView(isPresented: $isModalPresented, textFieldValue: $textFieldValue,appState: appState, exercise: appState.currentExercise, weight: appState.weight)
                .preferredColorScheme(.dark)
        }
    }

    var cardText: some View {
        VStack(alignment: .leading) {
            Text(workout_name)
                .font(.headline)
                .foregroundColor(Color.white)
            VStack(spacing: 4.0) {
                /*
                HStack() {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(time)
                }
                 */
                HStack() {
                    Image(systemName: "flame")
                        .foregroundColor(.red)
                    Text(calories)
                }
            }.foregroundColor(.gray)
        }
        .padding()
    }
}

struct ModalView: View {
    @Binding var isPresented: Bool
    @Binding var textFieldValue: String
    @State private var workoutTime: Int = 1
    @State var calBurn: Double = 0
    var appState: AppState
    
    var exercise = "Lifting"
    var weight: Double = 50.0
    
    var body: some View {
        PowerCard(title: "Settings", desc: "Change workout info", image: "Gear")
        VStack(spacing: 32) {
            Text("You will do the workout, \(exercise)")
                .font(.title2)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Minutes you will workout")
                        .font(.headline)
                        .padding(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        
                    Spacer()
                }
                
                Stepper(value: $workoutTime, in: 1...15) {
                    Text("\(workoutTime)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You would burn")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(String(format: "%.2f cals", calBurn))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.orange)
                            .onChange(of: workoutTime, perform: { value in
                                // Update burnedCalories when workoutTime changes
                                calBurn = Double(getCaloriesBurned())
                            })
                    }
                    
                    Spacer()
                }
            }
            

            HStack(spacing: 40) {
                Text("Close")
                    .foregroundColor(.red)
                    .onTapGesture {
                        isPresented = false
                    }
                    
                Text("Confirm")
                    .foregroundColor(.green)
                    .onTapGesture {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            appState.theTime = workoutTime
                            appState.calorieIncrement = Float(getCaloriesBurned()) / (Float(workoutTime) * 60)
                            print(appState.calorieIncrement)
                            appState.showPopover.toggle()
                        }
                    }
            }

            
        }
        .padding()
        .cornerRadius(10)
        .shadow(radius: 10)
        .preferredColorScheme(.dark)
        .onAppear {
            calBurn = Double(getCaloriesBurned())
        }
    }
    
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
    
    func getCaloriesBurned() -> Int {
        // Call getExerciseInfo here and calculate the calories burned based on the workoutTime and MET
        if let currentExerciseDetails = getExerciseInfo(exerciseName: exercise), // Replace "YourExerciseName" with actual exercise name
           
           let met = currentExerciseDetails.details["MET"] as? Double {
            let timeInHours = Double(workoutTime) / 60.0 // Convert workoutTime from minutes to hours
            let caloriesBurned = met * weight * timeInHours
            return Int(caloriesBurned)
        }
        return 0
    }

}

struct WarmUpCard_Previews: PreviewProvider {
    static var previews: some View {
        WarmUpCard()
            .environmentObject(AppState())
    }
}
