import Foundation

struct PersonTotal: Identifiable, Hashable {
    let id: UUID
    let person: Person
    var paid: Decimal
    var owed: Decimal
    var net: Decimal { paid - owed }
}

struct PairwiseDebt: Identifiable, Hashable {
    let id = UUID()
    let from: Person
    let to: Person
    let amount: Decimal
}

struct SettlementSummary {
    var totals: [PersonTotal]
    var transfers: [PairwiseDebt]
    var rawMatrix: [UUID: [UUID: Decimal]] = [:] // from -> to -> amount
}
