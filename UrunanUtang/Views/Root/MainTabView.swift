import SwiftUI

struct MainTabView: View {
    @Environment(\.appEnvironment) private var env

    var body: some View {
        TabView {
            ExpenseListView()
                .tabItem { Label("Items", systemImage: "list.bullet") }

            SummaryView()
                .tabItem { Label("Summary", systemImage: "chart.pie") }

            PeopleView()
                .tabItem { Label("People", systemImage: "person.3") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.appEnvironment, .live)
    }
}

