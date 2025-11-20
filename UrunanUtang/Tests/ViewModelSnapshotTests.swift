import Testing
@testable import UrunanUtang

struct ViewModelSnapshotTests {
    @Test
    func summary_totals_not_empty_with_items() async throws {
        let calc = SettlementCalculator()
        let vm = SummaryViewModel()
        let p = [Person(name: "A"), Person(name: "B")]
        let items = [ExpenseItem(title: "X", price: 20000, buyer: p[0], participants: p, mode: .urunan)]
        vm.refresh(with: items, people: p, calculator: calc)
        #expect(!vm.summary.totals.isEmpty)
    }
}

