import Foundation

enum ShareMode: String, Codable, CaseIterable, Identifiable {
    case urunan
    case utang

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

