import SwiftUI

struct CSVImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var env

    @State private var csvText: String = ""
    @State private var previewRows: [[String]] = []
    @State private var parseError: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Paste CSV")) {
                    TextEditor(text: $csvText)
                        .frame(minHeight: 160)
                        .font(.system(.body, design: .monospaced))
                    HStack {
                        Button("Preview") { preview() }.disabled(csvText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Spacer()
                        Button("Import") { importNow() }.disabled(previewRows.isEmpty)
                    }
                }
                if let parseError { Section { Text(parseError).foregroundStyle(.red) } }
                if !previewRows.isEmpty {
                    Section(header: Text("Preview (first 10)")) {
                        ForEach(previewRows.prefix(10).indices, id: \.self) { i in
                            VStack(alignment: .leading) {
                                Text(previewRows[i].joined(separator: " · "))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import CSV")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
        }
    }

    private func preview() {
        parseError = nil
        previewRows = []
        let lines = csvText.split(whereSeparator: { $0.isNewline })
        guard !lines.isEmpty else { return }
        let body = lines.count > 1 ? Array(lines.dropFirst()) : Array(lines)
        var rows: [[String]] = []
        for line in body {
            rows.append(parseCSVLine(String(line)))
        }
        previewRows = rows
    }

    private func importNow() {
        Task {
            do {
                _ = try await env.io.import(csv: csvText, dataManager: env.dataManager)
                dismiss()
            } catch {
                parseError = error.localizedDescription
            }
        }
    }

    // local small parser consistent with ImportExportService.parseCSVLine
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

