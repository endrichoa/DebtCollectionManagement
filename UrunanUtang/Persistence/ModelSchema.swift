import Foundation
import SwiftData

enum ModelSchema {
    static func previewContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Person.self, ExpenseItem.self])
        return try! ModelContainer(for: schema, configurations: config)
    }
}
