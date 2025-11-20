import Foundation

final class SettlementCalculator {
    struct RunningTotal { var paid: Decimal = 0; var owed: Decimal = 0 }

    func summarize(items: [ExpenseItem], people: [Person]) -> SettlementSummary {
        var map: [UUID: RunningTotal] = Dictionary(uniqueKeysWithValues: people.map { ($0.id, RunningTotal()) })
        var directed: [UUID: [UUID: Decimal]] = [:] // from -> to -> amount

        for item in items {
            guard item.price > 0, let buyer = item.buyer else { continue }
            let participants = item.participants
            guard !participants.isEmpty else { continue }

            var perShare: Decimal = 0
            switch item.mode {
            case .urunan:
                perShare = item.price / Decimal(participants.count)
                for p in participants {
                    map[p.id, default: .init()].owed += perShare
                    if p.id != buyer.id {
                        directed[p.id, default: [:]][buyer.id, default: 0] += perShare
                    }
                }
            case .utang:
                // Each participant owes the full price (usually only one)
                for p in participants {
                    map[p.id, default: .init()].owed += item.price
                    if p.id != buyer.id {
                        directed[p.id, default: [:]][buyer.id, default: 0] += item.price
                    }
                }
            }
            map[buyer.id, default: .init()].paid += item.price
        }

        let totals: [PersonTotal] = people.map { person in
            let r = map[person.id, default: .init()]
            return PersonTotal(id: person.id, person: person, paid: r.paid, owed: r.owed)
        }

        let transfers = settleTransfers(from: totals)
        var summary = SettlementSummary(totals: totals, transfers: transfers)
        summary.rawMatrix = directed
        return summary
    }

    private func settleTransfers(from totals: [PersonTotal]) -> [PairwiseDebt] {
        var creditors: [(person: Person, amount: Decimal)] = totals.filter { $0.net > 0 }.map { ($0.person, $0.net) }
        let debtors: [(person: Person, amount: Decimal)] = totals.filter { $0.net < 0 }.map { ($0.person, -$0.net) }
        var result: [PairwiseDebt] = []

        var ci = 0
        for i in 0..<debtors.count {
            var dAmt = debtors[i].amount
            while dAmt > 0 && ci < creditors.count {
                var cAmt = creditors[ci].amount
                let pay = min(dAmt, cAmt)
                if pay > 0 {
                    result.append(PairwiseDebt(from: debtors[i].person, to: creditors[ci].person, amount: pay))
                    dAmt -= pay
                    cAmt -= pay
                    creditors[ci].amount = cAmt
                }
                if cAmt == 0 { ci += 1 }
            }
        }
        return result
    }
}
