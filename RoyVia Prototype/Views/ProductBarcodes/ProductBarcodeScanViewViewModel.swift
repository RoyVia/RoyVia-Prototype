import Foundation
import SwiftUI

class ProductBarcodeScanViewViewModel: ObservableObject {
    @Published var scannedCode: String? = nil
    @Published var ingredientData: IngredientData? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "sYnm3fNHFejMKSz10fWKFQPbmAKa58mBVnVewlHf"
    
    // Reset state
    func resetState() {
        scannedCode = nil
        ingredientData = nil
        errorMessage = nil
    }
    
    // Handle scanned barcode
    func handleScannedBarcode(_ code: String) {
        let trimmedCode = code.hasPrefix("0") ? String(code.dropFirst()) : code
        fetchIngredients(for: code, and: trimmedCode)
    }
    
    // Fetch ingredients from USDA database
    private func fetchIngredients(for originalBarcode: String, and trimmedBarcode: String) {
        self.ingredientData = nil
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            // Try fetching with the original barcode
            if await tryFetchingIngredients(for: originalBarcode) {
                return
            }
            
            // Try fetching with the trimmed barcode if the first attempt failed
            if await tryFetchingIngredients(for: trimmedBarcode) {
                return
            }
            
            // If both attempts failed, update the error message
            DispatchQueue.main.async {
                print("USDA barcode data acquisitoin failed")
                self.isLoading = false
                self.errorMessage = "This product is not registered in USDA database."
            }
        }
    }
    
    // Helper method to fetch ingredients for a given barcode
    private func tryFetchingIngredients(for barcode: String) async -> Bool {
        do {
            let encodedBarcode = barcode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? barcode
            let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(encodedBarcode)&api_key=\(apiKey)"
            
            let foodData: USDAFoodData = try await HTTPHandler.fetchData(from: url, as: USDAFoodData.self)
            
            if let firstFood = foodData.foods.first {
                DispatchQueue.main.async {
                    self.ingredientData = IngredientData(ingredients: firstFood.parseIngredients(), errorMessage: nil)
                    self.isLoading = false
                    print("Ingredient Fetch completed")
                }
                return true // Success
            }
        } catch {
            print("Failed to fetch data for barcode \(barcode): \(error.localizedDescription)")
        }
        return false // Failure
    }
}
