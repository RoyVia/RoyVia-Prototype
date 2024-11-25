import SwiftUI

struct ProductDetailView: View {
    let ingredients: [String]
    let errorMessage: String?
    
    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                // Show error message
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .font(.headline)
            } else if !ingredients.isEmpty {
                // Show ingredients list
                List(ingredients, id: \.self) { ingredient in
                    Text(ingredient)
                }
                .navigationTitle("Product Details")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("No data available.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
            }
        }
        .padding()
    }
}
