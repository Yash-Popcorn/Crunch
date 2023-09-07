/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's body.
*/

import SwiftUI
import UIKit
@main
struct MyApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Prevent the device from sleeping
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
    }
}
