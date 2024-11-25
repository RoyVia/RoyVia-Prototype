//
//  RoyViaView.swift
//  RoyVia Prototype
//
//  Created by Heesun Kim on 11/17/24.
//

import SwiftUI

struct RoyViaView: View {
    var body: some View {
        VStack{
            Text("RoyVia")
                .font(.system(size: 60, weight: .bold , design: .default))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            Text("Paving Healthier Future of Humankind").font(.system(size: 18))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    RoyViaView()
}
