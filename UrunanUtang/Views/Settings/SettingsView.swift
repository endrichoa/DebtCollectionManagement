import SwiftUI

struct SettingsView: View {
    @Environment(\.appEnvironment) private var env

    @State private var exportText: String = ""
    @State private var showingExport = false
    @State private var showingImport = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Currency")) {
                    Text("Locale: \(env.currency.locale.identifier)")
                }
                Section(header: Text("Data")) {
                    Button("Export CSV") {
                        exportText = env.io.exportCSV(items: env.dataManager.items)
                        showingExport = true
                    }
                    Button("Import CSV") { showingImport = true }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExport) {
                NavigationStack { ScrollView { Text(exportText).textSelection(.enabled).padding() }.navigationTitle("CSV").toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { showingExport = false } } } }
            }
            .sheet(isPresented: $showingImport) {
                CSVImportView()
            }
        }
    }
}
