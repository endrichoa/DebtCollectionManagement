import SwiftUI

struct AddButton: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: action) { Image(systemName: "plus") }
        }
    }
}

struct FilterButton: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: action) { Image(systemName: "line.3.horizontal.decrease.circle") }
        }
    }
}

