import Foundation
import SwiftData

enum SampleData {
    static func seedIfNeeded(_ context: ModelContext) throws {
        let fetch = FetchDescriptor<Person>()
        let existing = try context.fetch(fetch)
        if existing.isEmpty {
            let adli = Person(name: "Adli", emoji: "🧑🏻")
            let rizal = Person(name: "Rizal", emoji: "🧑🏽")
            let iko = Person(name: "Iko", emoji: "🧑🏼")
            context.insert(adli)
            context.insert(rizal)
            context.insert(iko)

            let i1 = ExpenseItem(title: "Makan siang", price: 60000, buyer: adli, participants: [adli, rizal, iko], mode: .urunan, date: .now, notes: "Nasi goreng + es teh")
            let i2 = ExpenseItem(title: "Bensin", price: 100000, buyer: rizal, participants: [adli], mode: .utang, date: .now, notes: "Pinjem dulu")
            let i3 = ExpenseItem(title: "Kopi", price: 30000, buyer: iko, participants: [adli, rizal, iko], mode: .urunan, date: .now, notes: "")
            context.insert(i1)
            context.insert(i2)
            context.insert(i3)
        }
    }
}

