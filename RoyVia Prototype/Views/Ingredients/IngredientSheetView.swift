import SwiftUI

struct IngredientSheetView: View {
    let ingredients: [String]
    let errorMessage: String?
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack{
                BackgroundView()
                    .opacity(0.4)
                VStack {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .font(.headline)
                    } else if !ingredients.isEmpty {
                        List(ingredients, id: \.self) { ingredient in
                            Text(ingredient)
                        }
                        .padding()
                        .scrollContentBackground(.hidden)
                    } else {
                        Text("No data available.")
                            .foregroundColor(.gray)
                            .font(.headline)
                            .padding()
                    }
                    
                    Spacer()
                    Button(action: {
                        onDismiss()
                    }) {
                        OutlineTextView(text: "Try Another Product")
                    }
                }
            }
            .navigationTitle("Ingredients")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
