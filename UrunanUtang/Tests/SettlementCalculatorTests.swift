import Testing
@testable import UrunanUtang

struct SettlementCalculatorTests {
    @Test
    func urunan_and_utang_examples() async throws {
        let calc = SettlementCalculator()
        let adli = Person(name: "Adli")
        let rizal = Person(name: "Rizal")
        let iko = Person(name: "Iko")

        let i1 = ExpenseItem(title: "Makan", price: 60000, buyer: adli, participants: [adli, rizal, iko], mode: .urunan)
        let i2 = ExpenseItem(title: "Bensin", price: 100000, buyer: rizal, participants: [adli], mode: .utang)
        let i3 = ExpenseItem(title: "Kopi", price: 30000, buyer: iko, participants: [adli, rizal, iko], mode: .urunan)

        let s = calc.summarize(items: [i1, i2, i3], people: [adli, rizal, iko])
        #expect(s.totals.count == 3)
        // Basic invariants: sum nets == 0
        let netSum = s.totals.map { $0.net }.reduce(0, +)
        #expect(netSum == 0)
    }
}

