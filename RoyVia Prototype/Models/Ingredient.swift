//
//  Item.swift
//  RoyVia Prototype
//
//  Created by Heesun Kim on 11/16/24.
//
import SwiftUI
import Foundation

enum IngredientCategory: String, Codable {
    case concerning = "Concerning"
    case moderate = "Moderate"
    case low = "Low"
    case recommending = "Recommending"
}

final class Ingredient: Codable, Identifiable {
    var id: String
    var name: String
    var category: IngredientCategory
    var shortDescription: String
    var cons: String
    var pros: String
    var hormones: String
    var references: [String]
    
    // MARK: - Initializer
    init(name: String) {
        self.id = UUID().uuidString // Automatically generate a UUID
        self.name = name
        self.category = .recommending
        self.shortDescription = ""
        self.cons = ""
        self.pros = ""
        self.hormones = ""
        self.references = []
    }
    
    init(name: String, category:IngredientCategory) {
        self.id = UUID().uuidString // Automatically generate a UUID
        self.name = name
        self.category = category
        self.shortDescription = ""
        self.cons = ""
        self.pros = ""
        self.hormones = ""
        self.references = []
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case category = "Category"
        case shortDescription = "ShortDescription"
        case cons = "Cons"
        case pros = "Pros"
        case hormones = "Hormones"
        case references = "References"
    }
    
    // MARK: - Custom Decoding (Ignoring 'id')
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString // Generate a new UUID instead of decoding it
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container
            .decode(IngredientCategory.self, forKey: .category)
        self.shortDescription = try container.decode(String.self, forKey: .shortDescription)
        
        self.cons = try container.decode(String.self, forKey: .cons)
        self.pros = try container.decode(String.self, forKey: .pros)
        self.hormones = try container
            .decode(String.self, forKey: .hormones)
        
        
        let referencesString = try container.decode(String.self, forKey: .references)
        self.references = referencesString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    func getColor() -> Color {
        if(self.category == .moderate) {
            return .blue
        }
        else if(self.category == .concerning) {
            return .orange
        }
        else if(self.category == .low) {
            return .white
        }
        else {
            return .green
        }
    }
    
    func getIcon() -> some View {
        if(self.category == .moderate) {
            return Image(systemName: "questionmark.circle")
                .foregroundColor(self.getColor())
        }
        else if(self.category == .concerning) {
            return Image(systemName: "exclamationmark.circle")
                .foregroundColor(self.getColor())
        }
        else if(self.category == .low) {
            return Image(systemName: "minus.circle")
                .foregroundColor(self.getColor())
        }
        else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(self.getColor())
        }
    }
}
