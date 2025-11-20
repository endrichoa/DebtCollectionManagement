import SwiftUI

struct ExpenseListView: View {
    @Environment(\.appEnvironment) private var env
    @StateObject private var vm: ExpenseListViewModel

    @State private var showingForm = false
    @State private var editingItem: ExpenseItem? = nil

    init() {
        _vm = StateObject(wrappedValue: ExpenseListViewModel(dataManager: AppEnvironment.live.dataManager))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Modern Filters Section
                    modernFilters
                        .background(Color(.systemBackground))

                    if filtered.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { item in
                                    ModernExpenseCard(item: item)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                editingItem = item
                                                showingForm = true
                                            }
                                        }
                                        .contextMenu {
                                            Button {
                                                Task { try? await vm.duplicate(item: item) }
                                            } label: {
                                                Label("Duplicate", systemImage: "doc.on.doc")
                                            }
                                            Button(role: .destructive) {
                                                Task { try? await vm.delete(items: [item]) }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                ExpenseFormView(item: editingItem)
                    .presentationDetents([.medium, .large])
                    .onDisappear { editingItem = nil }
            }
        }
    }

    private var filtered: [ExpenseItem] {
        env.filterSort.sort(items: env.filterSort.filter(items: env.dataManager.items, search: vm.searchText, person: vm.selectedPerson, mode: vm.selectedMode), by: vm.sort)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("No expenses yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Tap + to add your first expense")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var modernFilters: some View {
        VStack(spacing: 12) {
            // Mode Picker
            Picker("Mode", selection: $vm.selectedMode.animation(.spring(response: 0.3))) {
                Text("All").tag(ShareMode?.none)
                ForEach(ShareMode.allCases) { m in
                    Text(m.title).tag(ShareMode?.some(m))
                }
            }
            .pickerStyle(.segmented)

            // Search and Filters
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    TextField("Search expenses...", text: $vm.searchText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )

                Menu {
                    Button {
                        withAnimation { vm.selectedPerson = nil }
                    } label: {
                        Label("All People", systemImage: vm.selectedPerson == nil ? "checkmark" : "person.3")
                    }
                    Divider()
                    ForEach(env.dataManager.people) { p in
                        Button {
                            withAnimation { vm.selectedPerson = p }
                        } label: {
                            Label(
                                p.name,
                                systemImage: vm.selectedPerson?.id == p.id ? "checkmark" : "person"
                            )
                        }
                    }
                } label: {
                    Image(systemName: vm.selectedPerson == nil ? "person.3" : "person.fill")
                        .font(.subheadline)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.selectedPerson == nil ? Color(.systemGray6) : Color.blue.opacity(0.15))
                        )
                }

                Menu {
                    Button {
                        withAnimation { vm.sort = .newestFirst }
                    } label: {
                        Label("Newest First", systemImage: vm.sort == .newestFirst ? "checkmark" : "calendar")
                    }
                    Button {
                        withAnimation { vm.sort = .priceHighToLow }
                    } label: {
                        Label("Highest Price", systemImage: vm.sort == .priceHighToLow ? "checkmark" : "arrow.down")
                    }
                    Button {
                        withAnimation { vm.sort = .alphabetical }
                    } label: {
                        Label("A-Z", systemImage: vm.sort == .alphabetical ? "checkmark" : "textformat")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.subheadline)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Modern Expense Card
struct ModernExpenseCard: View {
    @Environment(\.appEnvironment) private var env
    let item: ExpenseItem

    private var gradient: LinearGradient {
        let baseColor = item.buyer?.colorHex ?? "#6366F1"
        let color = Color(hex: baseColor) ?? .blue

        return LinearGradient(
            colors: [
                color.opacity(0.1),
                color.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var accentColor: Color {
        Color(hex: item.buyer?.colorHex ?? "#6366F1") ?? .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: Title and Price
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    // Buyer info
                    if let buyer = item.buyer {
                        HStack(spacing: 6) {
                            if let emoji = buyer.emoji, !emoji.isEmpty {
                                Text(emoji)
                                    .font(.caption)
                            } else {
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 6, height: 6)
                            }

                            Text("Paid by \(buyer.name)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // Price with emphasis
                VStack(alignment: .trailing, spacing: 2) {
                    Text(env.currency.string(from: item.price))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(accentColor)
                        .monospacedDigit()
                }
            }

            // Participants row
            if !item.participants.isEmpty, let buyer = item.buyer {
                let owees = item.participants.filter { $0.id != buyer.id }
                if !owees.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Owed by")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(owees) { person in
                                    ParticipantChip(person: person)
                                }
                            }
                        }
                    }
                }
            }

            // Footer: Mode and Date
            HStack(spacing: 12) {
                // Mode badge
                HStack(spacing: 4) {
                    Image(systemName: item.mode == .urunan ? "person.3.fill" : "person.fill")
                        .font(.caption2)
                    Text(item.mode.title)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(accentColor.opacity(0.15))
                )
                .foregroundStyle(accentColor)

                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(item.date, style: .date)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(accentColor.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Participant Chip
struct ParticipantChip: View {
    let person: Person

    private var personColor: Color {
        Color(hex: person.colorHex ?? "#3B82F6") ?? .blue
    }

    var body: some View {
        HStack(spacing: 6) {
            // Avatar
            if let emoji = person.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.caption)
            } else {
                Circle()
                    .fill(personColor.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text(person.name.prefix(1).uppercased())
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(personColor)
                    )
            }

            Text(person.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(personColor.opacity(0.1))
        )
        .overlay(
            Capsule()
                .strokeBorder(personColor.opacity(0.2), lineWidth: 1)
        )
        .foregroundStyle(personColor)
    }
}
