import SwiftUI

struct FoodDataAnalysisView: View {
    @ObservedObject var rvDataViewModel: RVDataViewModel
    let ingredients: [String]
    let errorMessage: String?
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                    .opacity(0.4)
                
                VStack {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .font(.headline)
                    } else if rvDataViewModel.rvData != nil {
                        // Call the analyzeImpact function
                        let impacts = rvDataViewModel.analyzeImpact(inputIngredients: ingredients)
                        
                        if impacts.isEmpty {
                            VStack {
                                Text("No significant impacts found.")
                                    .font(.system(size: 20, weight: .bold)) // Larger, bold font
                                    .padding()
                                Image(systemName: "face.smiling.inverse") // Smiley face SF Symbol
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100) // Adjust size
                                    .foregroundColor(.green)
                                    .opacity(0.7) // Green color
                                List{
                                    IngredientListView(ingredients: ingredients)
                                }
                                .padding()
                                .scrollContentBackground(.hidden)
                            }
                        } else {
                            // Display impacts
                            List {
                                ForEach(impacts, id: \.name) { impact in
                                    Section(
                                        header: ImpactHeaderView(
                                            name: impact.name,
                                            impactCount: impact.hormones.count
                                        )
                                    ) {
                                        ForEach(impact.hormones, id: \.name) { hormoneImpact in
                                            VStack(alignment: .leading) {
                                                Text("Hormone: \(hormoneImpact.name)")
                                                    .font(.headline)
                                                Text("Impacted by:")
                                                ForEach(hormoneImpact.ingredients, id: \.self) { ingredient in
                                                    Text("- \(ingredient)")
                                                        .font(.subheadline)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                                IngredientListView(ingredients: ingredients)
                            }
                            .padding()
                            .scrollContentBackground(.hidden)
                        }
                    } else {
                        Text("Preparing Data.")
                            .foregroundColor(.gray)
                            .font(.headline)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onDismiss()
                    }) {
                        OutlineTextView(text: "Close")
                    }
                }
            }
            .navigationTitle("Health Impact(s)")
        }
    }
}

struct IngredientListView: View{
    let ingredients:[String]
    var body: some View{
        Section(header: Text("All Ingredients Provided").font(.headline)) {
            ForEach(ingredients, id: \.self) { ingredient in
                Text(ingredient)
                    .font(.body)
            }
        }
    }
}

struct ImpactHeaderView: View {
    let name: String
    let impactCount: Int
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 20, weight: .bold)) // Larger, bold font
                .foregroundColor(textColor(for: impactCount)) // Color based on impact
            Spacer()
            Text("\(impactCount) impact\(impactCount > 1 ? "s" : "")")
                .font(.system(size: 16, weight: .semibold)) // Smaller font for count
                .foregroundColor(textColor(for: impactCount)) // Same color as name
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
    // Function to determine background color based on impact count
    private func textColor(for count: Int) -> Color {
        switch count {
            case 0:
                return Color.gray.opacity(0.6) // Neutral gray for no impact
            case 1...2:
                return Color.yellow.opacity(0.8) // Mild warning
            case 3...5:
                return Color.orange.opacity(0.8) // Moderate warning
            default:
                return Color.red.opacity(0.8) // Severe warning
        }
    }
}
