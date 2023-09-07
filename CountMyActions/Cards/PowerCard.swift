//
//  PowerCard.swift
//  Crunch
//
//  Created by Yash Seth on 6/28/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct PowerCard: View {
    var title: String = "Improve yourself"
    var desc: String = "Bob"
    var image: String = "Weight"
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 100)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(image)
                        .scaledToFit()
                )
                .foregroundColor(Color("DarkGreen"))
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                Text(desc)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct PowerCard_Previews: PreviewProvider {
    static var previews: some View {
        PowerCard()
    }
}
