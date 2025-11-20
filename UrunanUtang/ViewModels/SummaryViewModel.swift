import Foundation

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published private(set) var summary: SettlementSummary = .init(totals: [], transfers: [])

    func refresh(with items: [ExpenseItem], people: [Person], calculator: SettlementCalculator) {
        summary = calculator.summarize(items: items, people: people)
    }
}

