import Foundation
import SwiftData

@Model
final class ExpenseItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var price: Decimal
    var date: Date
    var notes: String
    var modeRaw: String

    @Relationship(deleteRule: .nullify) var buyer: Person?
    @Relationship(deleteRule: .nullify) var participants: [Person]

    var mode: ShareMode {
        get { ShareMode(rawValue: modeRaw) ?? .urunan }
        set { modeRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), title: String, price: Decimal, buyer: Person?, participants: [Person], mode: ShareMode, date: Date = .now, notes: String = "") {
        self.id = id
        self.title = title
        self.price = price
        self.buyer = buyer
        self.participants = participants
        self.modeRaw = mode.rawValue
        self.date = date
        self.notes = notes
    }
}
