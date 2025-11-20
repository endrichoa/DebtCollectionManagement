import Foundation

@MainActor
final class ExpenseListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedMode: ShareMode? = nil
    @Published var selectedPerson: Person? = nil
    @Published var sort: FilterSortService.SortKey = .newestFirst

    private let dataManager: FirestoreDataManager

    init(dataManager: FirestoreDataManager) {
        self.dataManager = dataManager
    }

    func delete(items: [ExpenseItem]) async throws {
        for item in items {
            try await dataManager.deleteExpenseItem(item)
        }
    }

    func duplicate(item: ExpenseItem) async throws {
        try await dataManager.duplicateExpenseItem(item)
    }
}

