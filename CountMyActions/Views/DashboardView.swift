//
//  DashboardView.swift
//  Crunch
//
//  Created by Yash Seth on 6/28/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @State var showPopover = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            TabView {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text("Exercises & Meditation")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        Divider()
                        Text("Warm Ups")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white)
                            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(Array(Warmup.exercises.keys), id: \.self) { key in
                                    WarmUpCard(
                                        image: key,
                                        workout_name: key,
                                        time: "\(String(Warmup.exercises[key]!["Time"]!)) min",
                                        calories: "\(String(Warmup.exercises[key]!["MET"]!)) MET"
                                    )
                                }
                            }
                        }
                        Divider()
                        Text("Yoga")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white)
                            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(Array(Yoga.exercises.keys), id: \.self) { key in
                                    WarmUpCard(
                                        image: key,
                                        workout_name: key,
                                        time: "\(String(Yoga.exercises[key]!["Time"]!)) min",
                                        calories: "\(String(Yoga.exercises[key]!["MET"]!)) MET"
                                    )
                                }
                            }
                        }
                        Divider()
                        Text("Hard Workout")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white)
                            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(Array(HardWorkout.exercises.keys), id: \.self) { key in
                                    WarmUpCard(
                                        image: key,
                                        workout_name: key,
                                        time: "\(String(HardWorkout.exercises[key]!["Time"]!)) min",
                                        calories: "\(String(HardWorkout.exercises[key]!["MET"]!)) MET"
                                    )
                                }
                                
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black) // Background Color
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                StatsView().tabItem {
                    Label("Stats", systemImage: "gearshape")
                }
                

            }.onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor.black // change this to your desired color
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }

        }.fullScreenCover(isPresented: $appState.showPopover) {
            CameraWithPosesAndOverlaysView()
            
            /*
            ZStack {
                Color(red: 0, green: 0, blue: 0, opacity: 0.8).edgesIgnoringSafeArea(.all)
                VStack {
                    Image("Water Bottle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                    VStack(spacing: 6) {
                        Text("Are you sure?")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            .padding(.top, 5.0)
                            .background(.clear)
                        Text("You may leave the workout at any time. Remember to drink some water before the workout!")
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                        NavigationLink(
                            destination: CameraWithPosesAndOverlaysView(),
                            label: {
                                Button(action: {
                                        print("NavigationLink clicked!")
                                    }) {
                                        Text("Begin Workout")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .padding()
                                            .background(Color("Neon"))
                                            .cornerRadius(10)
                                    }
                            }
                        ).zIndex(100000)
                    }
                    
                    
                }
            }
            .presentationDetents([.height(400)])
             */
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AppState())
    }
}
