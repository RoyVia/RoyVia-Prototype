//
//  OutlineTextButton.swift
//  RoyVia Prototype
//
//  Created by Heesun Kim on 11/17/24.
//

import SwiftUI

struct OutlineTextView: View {
    @State var text:String
    
    var body: some View {
        Text(self.text)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 200)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.white,
                        lineWidth: 2
                    )
            )
    }
}

