import Foundation

final class ImportExportService {
    // CSV: title,price,buyer,participants,mode,date,notes
    func exportCSV(items: [ExpenseItem]) -> String {
        var rows: [String] = ["title,price,buyer,participants,mode,date,notes"]
        let df = ISO8601DateFormatter()
        for i in items {
            let participants = i.participants.map { $0.name }.joined(separator: ";")
            let date = df.string(from: i.date)
            let priceString = NSDecimalNumber(decimal: i.price).stringValue
            let row = [i.title, priceString, i.buyer?.name ?? "", participants, i.mode.rawValue, date, i.notes]
                .map { escapeCSV($0) }
                .joined(separator: ",")
            rows.append(row)
        }
        return rows.joined(separator: "\n")
    }

    @MainActor
    func `import`(csv: String, dataManager: FirestoreDataManager) async throws -> [ExpenseItem] {
        var items: [ExpenseItem] = []
        let lines = csv.split(whereSeparator: { $0.isNewline })
        guard !lines.isEmpty else { return [] }
        let body = lines.dropFirst() // skip header
        let df = ISO8601DateFormatter()
        for line in body {
            let cols = parseCSVLine(String(line))
            guard cols.count >= 7 else { continue }
            let title = cols[0]
            let price = Decimal(string: cols[1]) ?? 0
            let buyerName = cols[2].trimmingCharacters(in: CharacterSet.whitespaces)
            let participantNames = cols[3].split(separator: ";").map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
            let mode = ShareMode(rawValue: cols[4]) ?? .urunan
            let date = df.date(from: cols[5]) ?? .now
            let notes = cols[6]

            // Resolve buyer and participants
            let buyer = try await resolvePerson(named: buyerName, dataManager: dataManager)
            var participants: [Person] = []
            for name in participantNames {
                if let person = try await resolvePerson(named: String(name), dataManager: dataManager) {
                    participants.append(person)
                }
            }
            
            let item = try await dataManager.addExpenseItem(
                title: title,
                price: price,
                buyer: buyer,
                participants: participants,
                mode: mode,
                date: date,
                notes: notes
            )
            items.append(item)
        }
        return items
    }

    @MainActor
    private func resolvePerson(named name: String, dataManager: FirestoreDataManager) async throws -> Person? {
        guard !name.isEmpty else { return nil }
        // Check if person already exists in dataManager
        if let found = dataManager.people.first(where: { $0.name == name }) {
            return found
        }
        // Create new person
        return try await dataManager.addPerson(name: name)
    }

    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        var it = line.makeIterator()
        while let ch = it.next() {
            if ch == "\"" {
                if inQuotes {
                    if let peek = it.next() {
                        if peek == "\"" {
                            current.append("\"")
                        } else if peek == "," {
                            result.append(current)
                            current = ""
                            inQuotes = false
                        } else {
                            inQuotes = false
                        }
                    } else {
                        inQuotes = false
                    }
                } else {
                    inQuotes = true
                }
            } else if ch == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(ch)
            }
        }
        result.append(current)
        return result
    }
}
