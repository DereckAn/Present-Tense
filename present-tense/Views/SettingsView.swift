//
//  SettingsView.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/29/25.
//


import SwiftUI

struct SettingsView: View {
    // Accede a la misma preferencia guardada en UserDefaults usando @AppStorage
    // DEBE usar la misma clave ("colorSchemePreference") que en ContentView
    @AppStorage("colorSchemePreference") private var colorSchemeOption: ColorSchemeOption = .system

    var body: some View {
        // Usamos NavigationView para tener un título claro en la pantalla de Ajustes
        NavigationView {
            Form { // Form da un estilo estándar de "Ajustes"
                Section(header: Text("Apariencia")) {
                    // Picker para seleccionar el modo
                    Picker("Modo de Color", selection: $colorSchemeOption) {
                        // Itera sobre todas las opciones del Enum
                        ForEach(ColorSchemeOption.allCases) { option in
                            Text(option.displayName).tag(option) // Muestra el nombre y usa el enum como tag
                        }
                    }
                    // Opcional: Estilo del Picker (inline se ve bien en Forms)
                    // .pickerStyle(.inline) // Puedes probar .segmented también
                }

                // --- Otras Secciones de Ajustes ---
                Section(header: Text("Cuenta")) {
                     Text("Gestionar cuenta...")
                     Text("Privacidad...")
                 }

                 Section(header: Text("Acerca de")) {
                     HStack {
                         Text("Versión")
                         Spacer()
                         Text("1.0.0") // Ejemplo
                     }
                 }
            }
            .navigationTitle("Ajustes") // Título de la pantalla
            // .navigationBarTitleDisplayMode(.inline) // Opcional: estilo del título
        }
        // Importante: Si SettingsView está dentro de la jerarquía de ContentView
        // que ya tiene .preferredColorScheme(), esta vista también lo heredará.
        // No necesitas aplicarlo de nuevo aquí usualmente.
    }
}

#Preview {
    SettingsView()
}