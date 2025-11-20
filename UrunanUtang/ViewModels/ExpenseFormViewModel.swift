import Foundation

@MainActor
final class ExpenseFormViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var priceText: String = ""
    @Published var date: Date = .now
    @Published var buyerID: UUID? = nil
    @Published var participantIDs: Set<UUID> = []
    @Published var mode: ShareMode = .urunan
    @Published var notes: String = ""

    var isValid: Bool {
        let hasBasics = !title.trimmingCharacters(in: .whitespaces).isEmpty && parsedPrice > 0 && buyerID != nil
        switch mode {
        case .urunan:
            return hasBasics && !participantIDs.isEmpty
        case .utang:
            return hasBasics && participantIDs.count == 1
        }
    }

    private let currency: CurrencyFormattingService
    private let dataManager: FirestoreDataManager

    init(currency: CurrencyFormattingService, dataManager: FirestoreDataManager) {
        self.currency = currency
        self.dataManager = dataManager
    }

    var parsedPrice: Decimal {
        currency.decimal(from: priceText) ?? 0
    }

    func load(item: ExpenseItem) {
        title = item.title
        priceText = currency.string(from: item.price)
        date = item.date
        buyerID = item.buyer?.id
        participantIDs = Set(item.participants.map { $0.id })
        mode = item.mode
        notes = item.notes
    }

    func save(editing item: ExpenseItem?, people: [Person]) async throws {
        guard isValid else { throw FirestoreError.invalidData("Form is not valid") }
        let price = parsedPrice
        let buyer = people.first(where: { $0.id == buyerID })
        let participants = people.filter { participantIDs.contains($0.id) }

        if let item {
            // Update existing item
            item.title = title
            item.price = price
            item.date = date
            item.buyer = buyer
            item.participants = participants
            item.mode = mode
            item.notes = notes
            try await dataManager.updateExpenseItem(item)
        } else {
            // Create new item
            _ = try await dataManager.addExpenseItem(
                title: title,
                price: price,
                buyer: buyer,
                participants: participants,
                mode: mode,
                date: date,
                notes: notes
            )
        }
    }
}
