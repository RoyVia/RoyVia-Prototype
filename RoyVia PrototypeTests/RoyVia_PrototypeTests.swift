//
//  RoyVia_PrototypeTests.swift
//  RoyVia PrototypeTests
//
//  Created by Heesun Kim on 11/16/24.
//

import Testing
import Foundation
@testable import RoyVia_Prototype

struct RoyVia_PrototypeTests {

    @Test func example() async throws {
        let jsonData = """
{
    "foods": [
        {
            "fdcId": 737572,
            "description": "BURRATA, LEMON ZEST & HERB",
            "dataType": "Branded",
            "gtinUpc": "012345678905",
            "publishedDate": "2019-12-06",
            "brandOwner": "GOOD & GATHER",
            "ingredients": "TURKEY BREAST, TURKEY BROTH",
            "marketCountry": "United States",
            "foodCategory": "Pepperoni, Salami & Cold Cuts"
        }
    ]
}
""".data(using: .utf8)!
        
        do {
            let decodedResponse = try JSONDecoder().decode(USDAFoodData.self, from: jsonData)
            print(decodedResponse)
        } catch {
            print("Decoding failed: \(error)")
        }

    }

}
