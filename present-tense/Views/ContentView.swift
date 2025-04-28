import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DayLogViewModel()
    @State private var showingAddEditSheet = false
    @State private var activityToEdit: ActivityLog? = nil
    @State private var selectedTab: Tab = .timeline // Pestaña inicial

    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenido principal de la pantalla
            VStack(spacing: 0) {
                // El contenido AHORA se determina completamente por el tab
                tabContentView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Espacio muerto inferior para la TabBar
                Spacer().frame(height: 90) // Ajusta si la altura de tu TabBar cambió

            } // Fin VStack principal del contenido
             // .ignoresSafeArea(edges: .bottom) // Considera si es necesario

            // Barra de Navegación Inferior Personalizada
            CustomTabView(selectedTab: $selectedTab) {
                // Acción del botón "+"
                activityToEdit = nil
                showingAddEditSheet = true
            }

        } // Fin ZStack principal
        .sheet(isPresented: $showingAddEditSheet) {
            // Asegúrate de pasar el ViewModel correcto
            AddEditActivityView(viewModel: viewModel, activityToEdit: activityToEdit)
                // Considera añadir .interactiveDismissDisabled() si no quieres que se cierre por swipe
        }
        .navigationBarHidden(true) // Mantiene la barra de sistema oculta
    }

    // Función ViewBuilder para el contenido de cada tab
    @ViewBuilder
    private func tabContentView() -> some View {
        switch selectedTab {
        case .timeline:
            // Muestra la vista Timeline dedicada
            TimelineView(viewModel: viewModel) { activity in
                // Acción que se ejecuta cuando se toca una actividad en TimelineView
                self.activityToEdit = activity
                self.showingAddEditSheet = true
            }
        case .calendar:
            // Vista Placeholder para Calendar
            Text("Calendar View")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.purple.opacity(0.1)) // Fondo para diferenciar
        case .diary:
            // Vista Placeholder para Diary
            Text("Diary View")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow.opacity(0.1)) // Fondo para diferenciar
        case .plan:
            // Vista Placeholder para Plan
            Text("Plan View")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green.opacity(0.1))
        case .settings:
            // Vista Placeholder para Settings
            Text("Settings View")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.orange.opacity(0.1))
        }
    }
}

// Preview para ContentView
#Preview {
    ContentView()
}
