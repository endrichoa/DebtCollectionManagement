import Testing
@testable import UrunanUtang
import SwiftData

struct ImportExportServiceTests {
    @Test
    func roundtrip_csv() async throws {
        let container = ModelSchema.previewContainer()
        let context = ModelContext(container)
        let io = ImportExportService()

        let adli = Person(name: "Adli")
        context.insert(adli)
        let item = ExpenseItem(title: "Test", price: 123000, buyer: adli, participants: [adli], mode: .urunan, notes: "note")
        context.insert(item)

        let csv = io.exportCSV(items: [item])
        let imported = try io.import(csv: csv, context: context)
        #expect(!imported.isEmpty)
    }
}

