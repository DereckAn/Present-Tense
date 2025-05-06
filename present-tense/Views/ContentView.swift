import SwiftUI

struct ContentView: View {
    // Variable de estado vinculada a UserDefaults para guardar la preferencia de color
    @AppStorage("colorSchemePreference") private var colorSchemeOption: ColorSchemeOption = .system

    var body: some View {
        MainTabView() // ContentView ahora simplemente presenta MainTabView
            // APLICA EL ESQUEMA DE COLOR PREFERIDO A TODA LA VISTA CONTENIDA
            .preferredColorScheme(colorSchemeOption.toSwiftUIScheme())
    }
}

#Preview {
    ContentView()
}
