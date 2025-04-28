//
//  AddEditActivityView.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

struct AddEditActivityView: View {
    @Environment(\.dismiss) var dismiss // Para cerrar la vista modal
    @ObservedObject var viewModel: DayLogViewModel // Acceso al ViewModel

    // Estados locales para el formulario
    @State private var description: String
    @State private var timestamp: Date

    // Opcional: La actividad que se está editando (nil si es nueva)
    var activityToEdit: ActivityLog?

    // Determina el título y el texto del botón
    private var isEditing: Bool { activityToEdit != nil }
    private var viewTitle: String { isEditing ? "Editar Actividad" : "Nueva Actividad" }
    private var saveButtonText: String { isEditing ? "Guardar Cambios" : "Añadir Actividad" }

    // Inicializador
    init(viewModel: DayLogViewModel, activityToEdit: ActivityLog? = nil) {
        self.viewModel = viewModel
        self.activityToEdit = activityToEdit
        // Inicializa los @State con los valores de la actividad a editar o valores por defecto
        _description = State(initialValue: activityToEdit?.description ?? "")
        _timestamp = State(initialValue: activityToEdit?.timestamp ?? Date()) // Hora actual por defecto
    }

    var body: some View {
        NavigationView { // O NavigationStack
            Form {
                Section(header: Text("Detalles de la Actividad")) {
                    // Usar TextEditor para descripciones potencialmente largas
                    TextEditor(text: $description)
                        .frame(minHeight: 100) // Darle un tamaño mínimo

                    DatePicker("Hora", selection: $timestamp, displayedComponents: .hourAndMinute)
                     // Si quieres permitir cambiar el día también:
                     // DatePicker("Fecha y Hora", selection: $timestamp)
                }
            }
            .navigationTitle(viewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón Cancelar (Izquierda)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                // Botón Guardar (Derecha)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(saveButtonText) {
                        saveActivity()
                        dismiss()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Deshabilitar si no hay descripción
                }
            }
        }
    }

    // Función para guardar (llama al método apropiado del ViewModel)
    private func saveActivity() {
        if let existingActivity = activityToEdit {
            // Editar: Crear una copia actualizada y pasarla al ViewModel
            var updatedActivity = existingActivity
            updatedActivity.description = description
            updatedActivity.timestamp = timestamp
            viewModel.updateActivity(activity: updatedActivity)
        } else {
            // Añadir: Llamar al método de añadir del ViewModel
            viewModel.addActivity(description: description, timestamp: timestamp)
        }
    }
}

// Preview para AddEditActivityView (requiere un ViewModel de muestra)
struct AddEditActivityView_Previews: PreviewProvider {
    static var previews: some View {
        // Vista de Añadir
        AddEditActivityView(viewModel: DayLogViewModel())

        // Vista de Editar (crea una actividad de ejemplo)
        let sampleActivity = ActivityLog(description: "Revisar código")
        AddEditActivityView(viewModel: DayLogViewModel(), activityToEdit: sampleActivity)
    }
}