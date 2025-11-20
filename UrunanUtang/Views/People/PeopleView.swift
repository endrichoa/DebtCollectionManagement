import SwiftUI

struct PeopleView: View {
    @Environment(\.appEnvironment) private var env
    @StateObject private var vm: PeopleViewModel
    @State private var showingAddForm = false
    @State private var editingPerson: Person?

    init() {
        _vm = StateObject(wrappedValue: PeopleViewModel(dataManager: AppEnvironment.live.dataManager))
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("People")) {
                    ForEach(env.dataManager.people) { person in
                        PersonRowView(person: person)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingPerson = person
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        try? await vm.delete(person)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    editingPerson = person
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                PersonFormView(person: nil) { name, emoji, hexColor in
                    let person = try await vm.add(name: name)
                    if let emoji = emoji {
                        person.emoji = emoji
                    }
                    if let hexColor = hexColor {
                        person.colorHex = hexColor
                    }
                    if emoji != nil || hexColor != nil {
                        try await vm.update(person)
                    }
                }
            }
            .sheet(item: $editingPerson) { person in
                PersonFormView(person: person) { name, emoji, hexColor in
                    person.name = name
                    person.emoji = emoji
                    person.colorHex = hexColor
                    try await vm.update(person)
                }
            }
        }
    }
}

struct PersonRowView: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            // Emoji or placeholder
            if let emoji = person.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 44, height: 44)
            } else {
                Circle()
                    .fill(personColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(person.name.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundColor(personColor)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                    .foregroundColor(personColor)

                if !person.isActive {
                    Text("Inactive")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Color indicator
            Circle()
                .fill(personColor)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
    }

    private var personColor: Color {
        if let hexString = person.colorHex {
            return Color(hex: hexString) ?? .blue
        }
        return .blue
    }
}

