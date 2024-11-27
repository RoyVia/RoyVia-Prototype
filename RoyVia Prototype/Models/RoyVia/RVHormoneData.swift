struct RVHormoneData: Codable {
    let name: String
    let shortDescription: String
    let relatedIngredients: [String]
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case shortDescription = "ShortDescription"
        case relatedIngredients = "RelatedIngredients"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        relatedIngredients = try container.decode([String].self, forKey: .relatedIngredients)
    }
}
