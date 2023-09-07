/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's camera with poses and the overlay view.
*/

import SwiftUI

struct CameraWithPosesAndOverlaysView: View {

    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = ViewModel()
    var healthStore: HealthStore?
    
    init() {
        healthStore = HealthStore()
    }
    
    var body: some View {
        NavigationView {
            OverlayView(count: viewModel.uiCount, calories: viewModel.calories) {
                viewModel.onCameraButtonTapped()
            }
            .background {
                if let (image, poses) = viewModel.liveCameraImageAndPoses {
                    CameraView(
                        cameraImage: image
                    )
                    .overlay {
                        PosesView(poses: poses)
                    }
                    .ignoresSafeArea()
                }
            }
            .onAppear {
                viewModel.initialize(exercise: appState.currentExercise, cal: Float(appState.calorieIncrement))
            }
            .onDisappear {
                viewModel.stopVideoProcessing()
                appState.showPopover = false
                if let healthStore = healthStore {
                    healthStore.requestAuthorization { success in
                        if success {
                            print("Got Access")
                            healthStore.addActiveEnergyBurned(Double(viewModel.calories), date: Date()) { (success, error) in
                                if success {
                                    print("Active energy burned data was added successfully")
                                } else {
                                    print("Failed to add active energy burned data: \(String(describing: error))")
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
}

struct CameraWithOverlaysView_Previews: PreviewProvider {
    static var previews: some View {
        CameraWithPosesAndOverlaysView()
            .environmentObject(AppState())
    }
}
