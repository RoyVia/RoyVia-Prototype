import SwiftUI

class RVDataViewModel: ObservableObject {
    @Published var rvData: RVDBData? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    private let apiServiceURL: String = "https://script.google.com/macros/s/AKfycbyOOtSH8sFuMNAUuWwKBYGD6i6Ug8P28EPU9jUBhJtBDNdmbU7VvI82nsf0CJxeadGN/exec?action=getAllSeparatedData"
    
    func fetchData() async {
        // Start loading state on the main thread
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Fetch data in a background thread
            let fetchedData: RVDBData = try await HTTPHandler.fetchData(
                from: apiServiceURL,
                as: RVDBData.self
            )
            
            // Update state on the main thread
            await MainActor.run {
                self.rvData = fetchedData
                self.isLoading = false
            }
        } catch {
            // Handle errors and update the state on the main thread
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    struct AreaOfConcernImpact {
        let name: String
        let hormones: [HormoneImpact]
    }
    
    struct HormoneImpact {
        let name: String
        let ingredients: [String]
    }
    
    func analyzeImpact(
        inputIngredients: [String]
    ) -> [AreaOfConcernImpact] {
        var result: [AreaOfConcernImpact] = []
        
        if let rvData = self.rvData {
            // Normalize input ingredients to lowercase for case-insensitive comparison
            let normalizedInputString = inputIngredients
                .map { $0.lowercased() }
                .joined(separator: " ")
            
            // Create a mapping between scanned and rvData ingredient names
            var ingredientMapping: [String: String] = [:]
            
            for scannedIngredient in inputIngredients {
                let normalizedScannedIngredient = scannedIngredient.lowercased()
                if let matchingRVIngredient = rvData.ingredients.first(where: { normalizedInputString.contains($0.name.lowercased()) && normalizedScannedIngredient.contains($0.name.lowercased()) }) {
                    ingredientMapping[matchingRVIngredient.name.lowercased()] = scannedIngredient
                }
            }
            
            // Step 1: Filter ingredients from RVDBData that match input ingredients
            let matchingIngredients = rvData.ingredients.filter { ingredient in
                ingredientMapping.keys.contains(ingredient.name.lowercased())
            }
            
            // Step 2: Map matching ingredients to their related hormones
            let hormonesImpacted = rvData.hormones.filter { hormone in
                !hormone.relatedIngredients.filter { ingredient in
                    ingredientMapping.keys.contains(ingredient.lowercased())
                }.isEmpty
            }
            
            // Step 3: Map impacted hormones to their related areas of concern
            let areasImpacted = rvData.areasOfConcern.filter { area in
                !area.relatedHormones.filter { hormone in
                    hormonesImpacted.map { $0.name.lowercased() }.contains(hormone.lowercased())
                }.isEmpty
            }
            
            for area in areasImpacted {
                // Get the impacted hormones for this area
                let impactedHormones = hormonesImpacted.filter { hormone in
                    area.relatedHormones.contains { $0.lowercased() == hormone.name.lowercased() }
                }
                
                // Map hormones to their related ingredients, using scanned names
                let hormoneImpacts: [HormoneImpact] = impactedHormones.map { hormone in
                    let relatedIngredients = hormone.relatedIngredients.compactMap { ingredient in
                        ingredientMapping[ingredient.lowercased()]
                    }
                    return HormoneImpact(name: hormone.name, ingredients: relatedIngredients)
                }
                
                // Create an AreaOfConcernImpact object
                result.append(AreaOfConcernImpact(name: area.name, hormones: hormoneImpacts))
            }
        }
        
        return result
    }



}
