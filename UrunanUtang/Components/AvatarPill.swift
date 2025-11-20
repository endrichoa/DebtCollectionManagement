import SwiftUI

struct AvatarPill: View {
    let name: String
    let emoji: String?
    var size: CGFloat = 24
    var compact: Bool = false
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: size, height: size)
                if let emoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: size * 0.7))
                } else {
                    Text(initials(from: name))
                        .font(.system(size: size * 0.45, weight: .semibold))
                        .foregroundStyle(.accent)
                }
            }
            Text(name)
                .font(compact ? .caption2 : .subheadline)
        }
        .padding(.vertical, compact ? 4 : 6)
        .padding(.horizontal, compact ? 8 : 10)
        .background(Capsule().fill(Color.accentColor.opacity(0.08)))
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }
        return String(initials)
    }
}
