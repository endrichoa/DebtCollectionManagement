import SwiftUI

struct PersonChipsPicker: View {
    let people: [Person]
    @Binding var selectionIDs: Set<UUID>
    var maxSelection: Int? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(people) { p in
                    let selected = selectionIDs.contains(p.id)
                    Button(action: { toggle(p) }) {
                        HStack(spacing: 6) {
                            if let emoji = p.emoji, !emoji.isEmpty {
                                Text(emoji)
                            } else {
                                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                            }
                            Text(p.name)
                        }
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule().fill(selected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }.padding(.vertical, 4)
        }
    }

    private func toggle(_ p: Person) {
        if selectionIDs.contains(p.id) {
            selectionIDs.remove(p.id)
        } else {
            if let max = maxSelection, selectionIDs.count >= max {
                // Replace with the new single selection when constrained
                selectionIDs = [p.id]
            } else {
                selectionIDs.insert(p.id)
            }
        }
    }
}
