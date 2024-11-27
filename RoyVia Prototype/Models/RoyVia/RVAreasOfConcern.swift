struct RVAreasOfConcern: Codable {
    let name: String
    let shortDescription: String
    let relatedHormones: [String]
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case shortDescription = "ShortDescription"
        case relatedHormones = "RelatedHormones"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        relatedHormones = try container.decode([String].self, forKey: .relatedHormones)
    }

}
