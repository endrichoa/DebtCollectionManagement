import SwiftUI

struct PersonFormView: View {
    @Environment(\.dismiss) private var dismiss
    let person: Person?
    let onSave: (String, String?, String?) async throws -> Void

    @State private var name: String
    @State private var emoji: String
    @State private var selectedColor: Color
    @State private var customHex: String
    @State private var useCustomHex: Bool = false

    private let predefinedColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]

    init(person: Person?, onSave: @escaping (String, String?, String?) async throws -> Void) {
        self.person = person
        self.onSave = onSave

        // Initialize state
        _name = State(initialValue: person?.name ?? "")
        _emoji = State(initialValue: person?.emoji ?? "")

        // Parse existing color or use default
        if let hexString = person?.colorHex,
           let color = Color(hex: hexString) {
            _selectedColor = State(initialValue: color)
            _customHex = State(initialValue: hexString)
            _useCustomHex = State(initialValue: !predefinedColors.contains(where: { $0.toHex() == hexString }))
        } else {
            _selectedColor = State(initialValue: .blue)
            _customHex = State(initialValue: "#0000FF")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section(header: Text("Emoji (Optional)")) {
                    TextField("Emoji", text: $emoji)
                        .font(.system(size: 40))
                        .multilineTextAlignment(.center)
                        .onChange(of: emoji) { _, newValue in
                            // Limit to single emoji
                            if newValue.count > 2 {
                                emoji = String(newValue.prefix(2))
                            }
                        }

                    Text("Tap to add an emoji (e.g., 😀 🎉 ⭐️)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Color (Optional)")) {
                    Toggle("Use Custom Hex Color", isOn: $useCustomHex)

                    if useCustomHex {
                        HStack {
                            TextField("Hex Color", text: $customHex)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .onChange(of: customHex) { _, newValue in
                                    if let color = Color(hex: newValue) {
                                        selectedColor = color
                                    }
                                }

                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedColor)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }

                        Text("Enter hex color (e.g., #FF5733)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                            ForEach(predefinedColors.indices, id: \.self) { index in
                                let color = predefinedColors[index]
                                Circle()
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                selectedColor.toHex() == color.toHex() ? Color.primary : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                        customHex = color.toHex() ?? "#0000FF"
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            if !emoji.isEmpty {
                                Text(emoji)
                                    .font(.system(size: 60))
                            }
                            Text(name.isEmpty ? "Preview" : name)
                                .font(.headline)
                                .foregroundColor(selectedColor)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(person == nil ? "Add Person" : "Edit Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                let finalEmoji = emoji.isEmpty ? nil : emoji
                                let finalHex = customHex.isEmpty ? nil : customHex
                                try await onSave(name, finalEmoji, finalHex)
                                dismiss()
                            } catch {
                                print("Failed to save person: \(error)")
                            }
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Color Extensions
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b: Double
        if hexSanitized.count == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }

        let r = components[0]
        let g = components.count > 1 ? components[1] : components[0]
        let b = components.count > 2 ? components[2] : components[0]

        let hexString = String(format: "#%02lX%02lX%02lX",
                              lroundf(Float(r * 255)),
                              lroundf(Float(g * 255)),
                              lroundf(Float(b * 255)))

        return hexString
    }
}
