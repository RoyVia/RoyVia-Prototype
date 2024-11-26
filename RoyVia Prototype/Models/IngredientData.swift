import SwiftUI

struct IngredientData: Equatable, Identifiable {
    let id = UUID()
    let ingredients: [String]
    let errorMessage: String?
}
