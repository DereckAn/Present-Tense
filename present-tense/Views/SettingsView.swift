import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @StateObject private var quickActionsViewModel = QuickActionsViewModel.shared
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingQuickActionsSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                // App Appearance
                appearanceSection
                
                // Activity Settings
                activitySection
                
                // Quick Actions
                quickActionsSection
                
                // Notifications
                notificationSection
                
                // Data Management
                dataSection
                
                // Cloud Sync
                cloudSection
                
                // App Information
                appInfoSection
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.large)
            .alert("Restablecer Datos", isPresented: $showingResetAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Restablecer", role: .destructive) {
                    settingsViewModel.resetAllData()
                }
            } message: {
                Text("Esta acción eliminará todos tus datos y configuraciones. Esta acción no se puede deshacer.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportDataView()
                    .environmentObject(settingsViewModel)
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportDataView()
                    .environmentObject(settingsViewModel)
            }
            .sheet(isPresented: $showingQuickActionsSettings) {
                QuickActionsSettingsView()
                    .environmentObject(quickActionsViewModel)
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("Apariencia") {
            Picker("Tema", selection: $settingsViewModel.colorSchemeOption) {
                ForEach(ColorSchemeOption.allCases) { option in
                    HStack {
                        Image(systemName: option.iconName)
                        Text(option.displayName)
                    }
                    .tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var activitySection: some View {
        Section("Actividades") {
            HStack {
                Text("Duración predeterminada")
                Spacer()
                Text(settingsViewModel.formatDuration(settingsViewModel.defaultActivityDuration))
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: $settingsViewModel.defaultActivityDuration,
                in: 15...240,
                step: 15
            ) {
                Text("Duración predeterminada")
            } minimumValueLabel: {
                Text("15m")
                    .font(.caption)
            } maximumValueLabel: {
                Text("4h")
                    .font(.caption)
            }
            
            Toggle("Detener automáticamente", isOn: $settingsViewModel.enableAutoStop)
            
            if settingsViewModel.enableAutoStop {
                HStack {
                    Text("Tiempo de auto-detención")
                    Spacer()
                    Text(settingsViewModel.formatDuration(settingsViewModel.autoStopDuration))
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $settingsViewModel.autoStopDuration,
                    in: 30...480,
                    step: 30
                ) {
                    Text("Tiempo de auto-detención")
                } minimumValueLabel: {
                    Text("30m")
                        .font(.caption)
                } maximumValueLabel: {
                    Text("8h")
                        .font(.caption)
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        Section("Acciones Rápidas") {
            Button("Gestionar acciones rápidas") {
                showingQuickActionsSettings = true
            }
            .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Configuradas: \(quickActionsViewModel.quickActions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !quickActionsViewModel.quickActions.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                        ForEach(Array(quickActionsViewModel.quickActions.prefix(8)), id: \.id) { action in
                            HStack(spacing: 4) {
                                Image(systemName: action.category.iconName)
                                    .font(.caption2)
                                    .foregroundColor(action.category.color)
                                
                                Text(action.title)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(action.category.color.opacity(0.1))
                            .foregroundColor(action.category.color)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
    
    private var notificationSection: some View {
        Section("Notificaciones") {
            Toggle("Habilitar notificaciones", isOn: $settingsViewModel.enableNotifications)
            
            if settingsViewModel.enableNotifications {
                Button("Configurar permisos") {
                    settingsViewModel.requestNotificationPermission()
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private var dataSection: some View {
        Section("Gestión de Datos") {
            Button("Exportar datos") {
                showingExportSheet = true
            }
            .foregroundColor(.blue)
            
            Button("Importar datos") {
                showingImportSheet = true
            }
            .foregroundColor(.blue)
            
            Button("Restablecer todos los datos") {
                showingResetAlert = true
            }
            .foregroundColor(.red)
        }
    }
    
    private var cloudSection: some View {
        Section("Sincronización en la Nube") {
            Toggle("Sincronizar con iCloud", isOn: $settingsViewModel.enableCloudSync)
            
            if settingsViewModel.enableCloudSync {
                HStack {
                    Text("Última sincronización")
                    Spacer()
                    Text(formatDate(settingsViewModel.lastSyncDate))
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                Button("Sincronizar ahora") {
                    Task {
                        await settingsViewModel.syncWithCloud()
                    }
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private var appInfoSection: some View {
        Section("Información de la App") {
            AppStatsRow(
                title: "Total de actividades",
                value: "\(settingsViewModel.totalActivities)"
            )
            
            AppStatsRow(
                title: "Tiempo total registrado",
                value: settingsViewModel.formattedTotalTime
            )
            
            AppStatsRow(
                title: "Días de uso",
                value: "\(settingsViewModel.daysOfUsage)"
            )
            
            AppStatsRow(
                title: "Versión",
                value: "\(settingsViewModel.appVersion) (\(settingsViewModel.buildNumber))"
            )
            
            // Favorite Categories
            if !settingsViewModel.favoriteCategories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categorías favoritas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(settingsViewModel.favoriteCategories, id: \.self) { category in
                            HStack(spacing: 4) {
                                Image(systemName: category.iconName)
                                    .font(.caption2)
                                    .foregroundColor(category.color)
                                
                                Text(category.displayName)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(category.color.opacity(0.1))
                            .foregroundColor(category.color)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct AppStatsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ExportDataView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                Text("Exportar Datos")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Esto creará un archivo JSON con todas tus actividades que puedes guardar como respaldo o compartir.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                if settingsViewModel.isExportingData {
                    ProgressView("Exportando datos...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button("Exportar Datos") {
                        Task {
                            await settingsViewModel.exportData()
                            showingShareSheet = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Exportar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }
}

struct ImportDataView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDocumentPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                Text("Importar Datos")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Selecciona un archivo JSON de respaldo para importar tus actividades. Esto reemplazará todos los datos actuales.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                if settingsViewModel.isImportingData {
                    ProgressView("Importando datos...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button("Seleccionar Archivo") {
                        showingDocumentPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Importar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker { url in
                Task {
                    await settingsViewModel.importData(from: url)
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

// MARK: - ColorSchemeOption Extension

extension ColorSchemeOption {
    var iconName: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}