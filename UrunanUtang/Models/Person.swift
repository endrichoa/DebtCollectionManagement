import Foundation
import SwiftData

@Model
final class Person: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var isActive: Bool
    var emoji: String?
    var colorHex: String?

    init(id: UUID = UUID(), name: String, isActive: Bool = true, emoji: String? = nil, colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.emoji = emoji
        self.colorHex = colorHex
    }
}

