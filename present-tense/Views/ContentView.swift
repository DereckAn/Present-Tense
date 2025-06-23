import SwiftUI

struct ContentView: View {
    @AppStorage("colorSchemePreference") private var colorSchemeOption: ColorSchemeOption = .system

    var body: some View {
        MainTabView()
            .preferredColorScheme(colorSchemeOption.toSwiftUIScheme())
    }
}

#Preview {
    ContentView()
}