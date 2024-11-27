struct RVDBData: Codable {
    //let currentVersion: RVDBVersion
    let areasOfConcern: [RVAreasOfConcern]
    let hormones: [RVHormoneData]
    let ingredients: [RVIngredientData]
    
    enum CodingKeys: String, CodingKey {
        //case currentVersion = "Version"
        case areasOfConcern = "AreasOfConcern"
        case hormones = "Hormones"
        case ingredients = "Ingredients"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //currentVersion = try container.decode(RVDBVersion.self, forKey: .currentVersion)
        areasOfConcern = try container.decode([RVAreasOfConcern].self, forKey: .areasOfConcern)
        hormones = try container.decode([RVHormoneData].self, forKey: .hormones)
        ingredients = try container.decode([RVIngredientData].self, forKey: .ingredients)
    }
    
}
