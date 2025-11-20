import Foundation

enum Validation {
    static func nonEmpty(_ text: String) -> Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    static func positive(_ value: Decimal) -> Bool { value > 0 }
}

