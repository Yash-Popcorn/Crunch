//
//  HomeView.swift
//  CountMyActions
//
//  Created by Yash Seth on 6/28/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var desc = """
        Your home exercise partner, delivering crucial health data during workouts.
    """
    var body: some View {
            NavigationView {
                VStack(alignment: .center) {
                    Text("A new oppurtunity")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Text("Report bugs to yashseth.vik@gmail.com")
                        .foregroundColor(Color.orange)
                    Image("Dumbell")
                        .resizable()
                        .padding(0.0)
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black]),
                                startPoint: UnitPoint(x: 0.5, y: 1),
                                endPoint: UnitPoint(x: 0.5, y: 0)
                            )
                        )
                    Text("Crunch")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Text(desc)
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.trailing)
                    VStack(spacing: 25) {
                        PowerCard(title: "Improve Yourself     ", desc: "Participate in meditation and hard workout  ", image: "Weight")
                        PowerCard(title: "See progress", desc: "Learn a variety of new things about yourself", image: "Heart")
                        NavigationLink(
                            destination: DashboardView().navigationBarBackButtonHidden(true),
                            label: {
                                Text("Start Now")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color("Neon"))
                                    .cornerRadius(10)
                            }
                        )

                    }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black) // Background Color
        }
        
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppState())
    }
}
