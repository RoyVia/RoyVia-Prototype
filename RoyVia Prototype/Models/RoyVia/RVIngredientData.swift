struct RVIngredientData: Codable {
    let name: String
    let riskCategory: String
    let shortDescription: String
    let cons: String
    let pros: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case riskCategory = "RiskCategory"
        case shortDescription = "ShortDescription"
        case cons = "Cons"
        case pros = "Pros"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        riskCategory = try container.decode(String.self, forKey: .riskCategory)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        cons = try container.decode(String.self, forKey: .cons)
        pros = try container.decode(String.self, forKey: .pros)
    }
}
