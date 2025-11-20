import SwiftUI

struct EmptyStateView: View {
    let title: String
    let actionTitle: String
    let action: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Button(actionTitle, action: action)
        }
        .padding()
    }
}

