import SwiftUI

struct MainTabView: View {
    // Estado para controlar el tab seleccionado
    @State private var selectedTab: AppTab = .timeline // Tab inicial por defecto
    
    // --- Instancias de ViewModels (si cada vista principal los necesita) ---
    // Si todas las vistas usan el mismo ViewModel, puedes pasarlo desde la App o ContentView
    // Si algunas vistas tienen sus propios ViewModels, los crearías aquí o en sus vistas.
    // Por ahora, asumimos que ContentView/TimelineView manejan el DayLogViewModel.
    
    // Referencia al DayLogViewModel para Timeline y la sheet de añadir
    @StateObject private var dayLogViewModel = DayLogViewModel()
    
    // Estado para la sheet de añadir actividad (ahora se manejaría aquí si el "+" se convierte en un botón en alguna vista)
    @State private var showingAddEditSheet = false
    @State private var activityToEdit: ActivityLog? = nil
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Vista para Timeline
            TimelineView(viewModel: dayLogViewModel) { activity in
                // Lógica para editar actividad (presentar sheet)
                self.activityToEdit = activity
                self.showingAddEditSheet = true
            }
            // El modificador .onAppear se puede usar si necesitas
            // hacer algo cuando la vista Timeline aparece.
            .onAppear {
                // Por ejemplo, si tuvieras un botón "+" en la barra de título
                // de TimelineView, aquí podrías configurar su acción.
                // O si DayLogViewModel necesita refrescarse al ver Timeline.
            }
            .tabItem {
                Label(AppTab.timeline.title, systemImage: AppTab.timeline.systemImageName)
            }
            .tag(AppTab.timeline)
            
            // -------- NUEVA VISTA DE CALENDARIO --------
            // Asegúrate de que tu target sea iOS 16+
            if #available(iOS 16.0, macOS 13.0, *) {
                AppCalendarView(viewModel: dayLogViewModel) // <--- USA EL NOMBRE RENOMBRADO
                    .tabItem {
                        Label(AppTab.calendar.title, systemImage: AppTab.calendar.systemImageName)
                    }
                    .tag(AppTab.calendar)
            } else {
                // Fallback para versiones anteriores si es necesario
                NavigationView {
                    Text("Calendario no disponible en esta versión de iOS.")
                        .navigationTitle(AppTab.calendar.title)
                }
                .tabItem {
                    Label(AppTab.calendar.title, systemImage: AppTab.calendar.systemImageName)
                }
                .tag(AppTab.calendar)
            }
            // ------------------------------------------
            
            // Vista para Diary (Placeholder)
            NavigationView {
                Text("Diary View")
                    .navigationTitle(AppTab.diary.title)
            }
            .tabItem {
                Label(AppTab.diary.title, systemImage: AppTab.diary.systemImageName)
            }
            .tag(AppTab.diary)
            
            // Vista para Plan (Placeholder)
            NavigationView {
                Text("Plan View")
                    .navigationTitle(AppTab.plan.title)
            }
            .tabItem {
                Label(AppTab.plan.title, systemImage: AppTab.plan.systemImageName)
            }
            .tag(AppTab.plan)
            
            // Vista para Settings
            // SettingsView ya tiene su propia NavigationView interna
            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.systemImageName)
                }
                .tag(AppTab.settings)
        }
        // Aplicar el tinte a toda la TabView (afecta iconos y texto seleccionado)
        .tint(.blue) // O el color primario de tu app
        // La sheet para añadir/editar actividad se presenta desde aquí
        .sheet(isPresented: $showingAddEditSheet) {
            AddEditActivityView(viewModel: dayLogViewModel, activityToEdit: activityToEdit)
        }
        // Ya no necesitas el .preferredColorScheme aquí si lo manejas en la vista raíz de la App
    }
}

#Preview {
    MainTabView()
    // Para previews, podrías inyectar un ViewModel de muestra
    // .environmentObject(DayLogViewModel()) // Si tus vistas hijas lo usan como environmentObject
}
