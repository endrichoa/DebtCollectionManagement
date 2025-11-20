import Foundation

final class FilterSortService {
    // Array-based helpers for views without complex predicates
    func filter(items: [ExpenseItem], search: String, person: Person?, mode: ShareMode?) -> [ExpenseItem] {
        var result = items
        if let mode { result = result.filter { $0.mode == mode } }
        if let person {
            result = result.filter { $0.buyer?.id == person.id || $0.participants.contains(where: { $0.id == person.id }) }
        }
        if !search.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(search) || $0.notes.localizedCaseInsensitiveContains(search) }
        }
        return result
    }

    func sort(items: [ExpenseItem], by key: SortKey) -> [ExpenseItem] {
        switch key {
        case .newestFirst: return items.sorted { $0.date > $1.date }
        case .priceHighToLow: return items.sorted { $0.price > $1.price }
        case .alphabetical: return items.sorted { $0.title < $1.title }
        }
    }

    enum SortKey { case newestFirst, priceHighToLow, alphabetical }
}

