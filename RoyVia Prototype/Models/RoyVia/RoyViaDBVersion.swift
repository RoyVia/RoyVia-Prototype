import SwiftData
import Foundation

@Model
final class RoyViaDBVersion: Codable, Equatable {
    @Attribute(.unique) var date: Date
    var revision: Int
    
    init(date: Date, revision: Int) {
        self.date = date
        self.revision = revision
    }
    
    // Composite unique key (Date + Revision)
    static func uniqueKey(for date: Date, revision: Int) -> String {
        "\(date.timeIntervalSince1970)-\(revision)"
    }
    
    // Comparison method to determine if an incoming version is newer
    func isNewerThan(_ other: RoyViaDBVersion) -> Bool {
        if self.date > other.date {
            return true
        } else if self.date == other.date && self.revision > other.revision {
            return true
        }
        return false
    }
    
    // Equatable conformance for comparing two objects
    static func == (lhs: RoyViaDBVersion, rhs: RoyViaDBVersion) -> Bool {
        lhs.date == rhs.date && lhs.revision == rhs.revision
    }
    
    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case date
        case revision
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.revision = try container.decode(Int.self, forKey: .revision)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(revision, forKey: .revision)
    }
}
