import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DayLogViewModel()
    @State private var showingAddEditSheet = false
    @State private var activityToEdit: ActivityLog? = nil
    @State private var selectedTab: Tab = .timeline

    // Variable de estado vinculada a UserDefaults para guardar la preferencia
    // Usa la clave "colorSchemePreference" y el valor por defecto .system (raw value 0)
    @AppStorage("colorSchemePreference") private var colorSchemeOption: ColorSchemeOption = .system

    var body: some View {
        ZStack(alignment: .bottom) {
            // ... (VStack principal y contenido del tab como antes) ...
             VStack(spacing: 0) {
                tabContentView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer().frame(height: 90)
            }

            CustomTabView(selectedTab: $selectedTab) {
                activityToEdit = nil
                showingAddEditSheet = true
            }

        }
        .sheet(isPresented: $showingAddEditSheet) {
            AddEditActivityView(viewModel: viewModel, activityToEdit: activityToEdit)
        }
        .navigationBarHidden(true)
        // APLICA EL ESQUEMA DE COLOR PREFERIDO A TODA LA VISTA
        .preferredColorScheme(colorSchemeOption.toSwiftUIScheme())
    }

    // Función ViewBuilder para el contenido de cada tab (actualizada para SettingsView)
    @ViewBuilder
    private func tabContentView() -> some View {
        switch selectedTab {
        case .timeline:
            TimelineView(viewModel: viewModel) { activity in
                self.activityToEdit = activity
                self.showingAddEditSheet = true
            }
        case .calendar:
            Text("Calendar View").font(.largeTitle).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.purple.opacity(0.1))
        case .diary:
            Text("Diary View").font(.largeTitle).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.yellow.opacity(0.1))
        case .plan:
            Text("Plan View").font(.largeTitle).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.green.opacity(0.1))
        case .settings:
            // Pasamos el Binding a la vista de Settings si es necesario,
            // pero como SettingsView usará @AppStorage también, no es estrictamente necesario
             SettingsView() // Llama a la nueva vista de configuración
        }
    }
}

// Preview para ContentView
#Preview {
    ContentView()
}
