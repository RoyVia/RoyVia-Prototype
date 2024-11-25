//
//  USDAModels.swift
//  RoyVia Prototype
//
//  Created by Heesun Kim on 11/22/24.
//

import Foundation

// Root response structure
struct USDAFoodData: Codable {
    let foods: [FoodItem]
}

struct FoodItem: Codable {
    let fdcId: Int
    let description: String
    let dataType: String?
    let gtinUpc: String?
    let publishedDate: String?
    let brandOwner: String?
    let ingredients: String?
    let marketCountry: String?
    let foodCategory: String?
    
    enum CodingKeys: String, CodingKey {
        case fdcId
        case description
        case dataType
        case gtinUpc = "gtin_upc" // Map to match the JSON
        case publishedDate
        case brandOwner
        case ingredients
        case marketCountry
        case foodCategory
    }
    
    func parseIngredients() -> [String] {
        var result: [String] = []
        var currentIngredient = ""
        var openParenthesesCount = 0
        
        for character in self.ingredients ?? ""{
            if character == "(" {
                openParenthesesCount += 1
            } else if character == ")" {
                openParenthesesCount -= 1
            }
            
            if character == "," && openParenthesesCount == 0 {
                // Split only if not inside parentheses
                result.append(currentIngredient.trimmingCharacters(in: .whitespacesAndNewlines))
                currentIngredient = ""
            } else {
                currentIngredient.append(character)
            }
        }
        
        // Append the last ingredient if any
        if !currentIngredient.isEmpty {
            result.append(currentIngredient.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return result
    }
    
}
