import SwiftUI

struct SummaryView: View {
    @Environment(\.appEnvironment) private var env
    @StateObject private var vm = SummaryViewModel()
    @Namespace private var animation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header with total overview
                headerSection

                // Main debts cards
                if !vm.summary.transfers.isEmpty {
                    settledDebtsSection
                }

                // Detailed breakdown
                if !pairKeys().isEmpty {
                    detailedBreakdownSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            vm.refresh(with: env.dataManager.items, people: env.dataManager.people, calculator: env.settle)
        }
        .onChange(of: env.dataManager.items) { _, _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                vm.refresh(with: env.dataManager.items, people: env.dataManager.people, calculator: env.settle)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settlement Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Who owes whom")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    // MARK: - Settled Debts Section
    private var settledDebtsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transfers Needed")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(vm.summary.transfers) { transfer in
                    ModernDebtCard(
                        from: transfer.from,
                        to: transfer.to,
                        amount: env.currency.string(from: transfer.amount),
                        isPrimary: true
                    )
                    .matchedGeometryEffect(id: transfer.id, in: animation)
                }
            }
        }
    }

    // MARK: - Detailed Breakdown Section
    private var detailedBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Balances")
                .font(.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(pairKeys()) { key in
                    let amount = vm.summary.rawMatrix[key.from.id]?[key.to.id] ?? 0
                    if amount > 0 {
                        CompactDebtCard(
                            from: key.from,
                            to: key.to,
                            amount: env.currency.string(from: amount)
                        )
                    }
                }
            }
        }
    }

    private struct PairKey: Identifiable { let id: String; let from: Person; let to: Person }
    private func pairKeys() -> [PairKey] {
        var keys: [PairKey] = []
        for a in env.dataManager.people {
            for b in env.dataManager.people where a.id != b.id {
                keys.append(.init(id: "\(a.id.uuidString)-\(b.id.uuidString)", from: a, to: b))
            }
        }
        // Stable order by from.name then to.name for predictable 2x3 layout
        return keys.sorted { (l, r) in
            if l.from.name != r.from.name { return l.from.name < r.from.name }
            return l.to.name < r.to.name
        }
    }
}

// MARK: - Modern Debt Card
struct ModernDebtCard: View {
    let from: Person
    let to: Person
    let amount: String
    let isPrimary: Bool

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: from.colorHex ?? "#6366F1") ?? Color.blue,
                Color(hex: to.colorHex ?? "#8B5CF6") ?? Color.purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        HStack(spacing: 16) {
            // From Person
            PersonAvatar(person: from, size: 44)

            VStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))

                Text(amount)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)

            // To Person
            PersonAvatar(person: to, size: 44)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(gradient)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Compact Debt Card
struct CompactDebtCard: View {
    let from: Person
    let to: Person
    let amount: String

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                PersonAvatar(person: from, size: 28)
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                PersonAvatar(person: to, size: 28)
            }

            Text(amount)
                .font(.system(.callout, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Person Avatar
struct PersonAvatar: View {
    let person: Person
    let size: CGFloat

    private var personColor: Color {
        Color(hex: person.colorHex ?? "#3B82F6") ?? .blue
    }

    var body: some View {
        ZStack {
            if let emoji = person.emoji, !emoji.isEmpty {
                Circle()
                    .fill(personColor.opacity(0.15))
                    .frame(width: size, height: size)

                Text(emoji)
                    .font(.system(size: size * 0.5))
            } else {
                Circle()
                    .fill(personColor.opacity(0.2))
                    .frame(width: size, height: size)

                Text(person.name.prefix(1).uppercased())
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(personColor)
            }
        }
        .overlay(
            Circle()
                .strokeBorder(personColor.opacity(0.3), lineWidth: 2)
        )
    }
}
