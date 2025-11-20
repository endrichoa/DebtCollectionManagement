import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var env

    @StateObject private var vm: ExpenseFormViewModel

    private let editingItem: ExpenseItem?

    init(item: ExpenseItem?) {
        self._vm = StateObject(wrappedValue: ExpenseFormViewModel(
            currency: .init(locale: Locale(identifier: "id_ID")),
            dataManager: AppEnvironment.live.dataManager
        ))
        self.editingItem = item
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detail")) {
                    TextField("Nama Item", text: $vm.title)
                    PriceTextField(text: $vm.priceText)
                    DatePicker("Tanggal", selection: $vm.date, displayedComponents: .date)
                    Picker("Yang beli", selection: Binding(get: { vm.buyerID }, set: { vm.buyerID = $0 })) {
                        Text("Pilih").tag(UUID?.none)
                        ForEach(env.dataManager.people) { p in Text(p.name).tag(UUID?.some(p.id)) }
                    }
                    ModeSegmentedPicker(mode: $vm.mode)
                }
                Section(header: Text("Peserta")) {
                    PersonChipsPicker(people: env.dataManager.people, selectionIDs: $vm.participantIDs, maxSelection: vm.mode == .utang ? 1 : nil)
                }
                Section(header: Text("Catatan")) {
                    TextField("Catatan", text: $vm.notes, axis: .vertical)
                }
            }
            .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Save") { save() }.disabled(!vm.isValid) }
            }
            .onAppear { if let item = editingItem { vm.load(item: item) } }
        }
    }

    private func save() {
        Task {
            do {
                try await vm.save(editing: editingItem, people: env.dataManager.people)
                dismiss()
            } catch {
                print("Failed to save expense: \(error)")
            }
        }
    }
}
#Preview {
    ExpenseFormView(item: nil)
}
