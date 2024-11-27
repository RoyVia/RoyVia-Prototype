//
//  RoyViaView.swift
//  RoyVia Prototype
//
//  Created by Heesun Kim on 11/17/24.
//

import SwiftUI

struct RoyViaView: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    
    var body: some View {
        VStack{
            Text("RoyVia")
                .font(.system(size: 60, weight: .bold , design: .default))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            Text("Paving Healthier Future of Humankind").font(.system(size: 18))
                .foregroundColor(.white)
                .padding()
            Text("Please note that this is an internal test version")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(.subheadline)
            Text("App Version: \(appVersion)")
                .font(.headline)
                .padding()
            Text("Build Number: \(buildNumber)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    RoyViaView()
}
