import Foundation
import SwiftUI

// MARK: - Environment Container
final class AppEnvironment: ObservableObject {
    let currency: CurrencyFormattingService
    let settle: SettlementCalculator
    let io: ImportExportService
    let filterSort: FilterSortService
    let cloud: FirestoreService
    let dataManager: FirestoreDataManager

    init(currency: CurrencyFormattingService,
         settle: SettlementCalculator,
         io: ImportExportService,
         filterSort: FilterSortService,
         cloud: FirestoreService,
         dataManager: FirestoreDataManager) {
        self.currency = currency
        self.settle = settle
        self.io = io
        self.filterSort = filterSort
        self.cloud = cloud
        self.dataManager = dataManager
    }

    @MainActor
    static let live: AppEnvironment = {
        let dataManager = FirestoreDataManager()
        return AppEnvironment(
            currency: CurrencyFormattingService(locale: Locale(identifier: "id_ID")),
            settle: SettlementCalculator(),
            io: ImportExportService(),
            filterSort: FilterSortService(),
            cloud: FirestoreService(),
            dataManager: dataManager
        )
    }()
}

// MARK: - SwiftUI Environment Key
private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
