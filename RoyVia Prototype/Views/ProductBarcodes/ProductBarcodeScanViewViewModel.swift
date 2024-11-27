import Foundation
import SwiftUI

class ProductBarcodeScanViewViewModel: ObservableObject {
    @Published var scannedCode: String? = nil
    @Published var ingredientData: IngredientData? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "sYnm3fNHFejMKSz10fWKFQPbmAKa58mBVnVewlHf"
    
    func resetState() {
        scannedCode = nil
        ingredientData = nil
        errorMessage = nil
    }
    
    func handleScannedBarcode(_ code: String) {
        let trimmedCode = code.hasPrefix("0") ? String(code.dropFirst()) : code
        fetchIngredients(for: code, and: trimmedCode)
    }
    
    private func fetchIngredients(for originalBarcode: String, and trimmedBarcode: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            let success = await withTaskGroup(of: Bool.self) { group in
                group.addTask { await self.tryFetchingIngredients(for: originalBarcode) }
                group.addTask { await self.tryFetchingIngredients(for: trimmedBarcode) }
                
                for await result in group {
                    if result { return true }
                }
                return false
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                if !success {
                    self.errorMessage = "This product is not registered in the USDA database."
                }
            }
        }
    }
    
    private func tryFetchingIngredients(for barcode: String) async -> Bool {
        do {
            let encodedBarcode = barcode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? barcode
            let url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(encodedBarcode)&api_key=\(apiKey)"
            
            let foodData: USDAFoodData = try await HTTPHandler.fetchData(from: url, as: USDAFoodData.self)
            
            if let firstFood = foodData.foods.first {
                DispatchQueue.main.async {
                    self.ingredientData = IngredientData(ingredients: firstFood.parseIngredients(), errorMessage: nil)
                }
                return true
            }
        } catch {
            print("Error fetching data for barcode \(barcode): \(error)")
        }
        return false
    }
}
