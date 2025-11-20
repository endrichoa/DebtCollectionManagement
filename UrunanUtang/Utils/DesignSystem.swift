import SwiftUI

enum DS {
    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
    enum Typography {
        static let title2: SwiftUI.Font = SwiftUI.Font.system(.title2, design: .rounded)
        static let headline: SwiftUI.Font = SwiftUI.Font.system(.headline, design: .rounded)
        static let caption: SwiftUI.Font = SwiftUI.Font.system(.caption, design: .rounded)
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .fill(Color.accentColor.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
    }
}

extension View {
    func cardBackground() -> some View { modifier(CardBackground()) }
}
