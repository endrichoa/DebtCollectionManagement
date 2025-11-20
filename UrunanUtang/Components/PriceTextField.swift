import SwiftUI

struct PriceTextField: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Text("Rp")
            TextField("Harga", text: $text)
                .keyboardType(.numberPad)
        }
    }
}

