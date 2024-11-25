//
//  BackgroundView.swift
//  RoyVia Prototype
//
//  Created by Heesun Kim on 11/16/24.
//

import SwiftUI

struct BackgroundView:View{
    
    var body: some View{
        LinearGradient(gradient: Gradient(
            colors: [Color(hex: "2F8155"), Color(hex: "0D0933")]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}
