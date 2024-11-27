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
        var iterator = self.ingredients?.makeIterator() ?? "".makeIterator()
        var character: Character? = iterator.next()
        
        while let char = character {
            if char == "(" {
                openParenthesesCount += 1
            } else if char == ")" {
                openParenthesesCount -= 1
            }
            
            // Check for `,` or `**` as delimiters outside parentheses
            if char == "," && openParenthesesCount == 0 {
                // Split on comma
                result.append(currentIngredient.trimmingCharacters(in: .whitespacesAndNewlines))
                currentIngredient = ""
            } else if char == "*" {
                // Check for `**` sequence
                let nextChar = iterator.next()
                if nextChar == "*" && openParenthesesCount == 0 {
                    // Split on `**`
                    result.append(currentIngredient.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentIngredient = ""
                    character = iterator.next() // Move to the next character after `**`
                    continue
                } else {
                    // Not a `**` sequence, append current `*` and continue
                    currentIngredient.append(char)
                    if let nextChar = nextChar { currentIngredient.append(nextChar) }
                    character = iterator.next()
                    continue
                }
            } else {
                // Append character to the current ingredient
                currentIngredient.append(char)
            }
            
            // Move to the next character
            character = iterator.next()
        }
        
        // Append the last ingredient if any
        if !currentIngredient.isEmpty {
            result.append(currentIngredient.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return result
    }

    
}
