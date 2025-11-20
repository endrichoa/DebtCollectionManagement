import SwiftUI

struct ModeSegmentedPicker: View {
    @Binding var mode: ShareMode
    var body: some View {
        Picker("Mode", selection: $mode) {
            Text("Urunan").tag(ShareMode.urunan)
            Text("Utang").tag(ShareMode.utang)
        }
        .pickerStyle(.segmented)
    }
}

