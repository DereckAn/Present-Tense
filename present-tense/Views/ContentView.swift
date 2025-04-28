//
//  ContentView.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

struct ContentView: View {
    // Instancia del ViewModel. @StateObject asegura que viva mientras la vista exista.
    @StateObject private var viewModel = DayLogViewModel()

    // Estado para controlar si se muestra la sheet de añadir/editar
    @State private var showingAddEditSheet = false
    @State private var activityToEdit: ActivityLog? = nil // Para saber qué editar

    var body: some View {
        NavigationView { // O NavigationStack para navegación más moderna
            VStack(alignment: .leading) {
                // Muestra un mensaje si no hay actividades para el día
                if viewModel.activitiesForSelectedDate.isEmpty {
                    Text("No hay actividades registradas para hoy.\n¡Añade tu primera actividad!")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Centrar en el espacio disponible
                } else {
                    // Lista de actividades
                    List {
                        // Podrías agrupar por hora o simplemente mostrar la lista
                        ForEach(viewModel.activitiesForSelectedDate) { activity in
                            ActivityRowView(activity: activity)
                                .contentShape(Rectangle()) // Hace toda la fila "tappable"
                                .onTapGesture {
                                    // Al tocar una fila, prepara para editarla
                                    activityToEdit = activity
                                    showingAddEditSheet = true
                                }
                        }
                        .onDelete(perform: viewModel.deleteActivity) // Añade swipe-to-delete
                    }
                    // Opcional: Estilo de lista (si quieres quitar separadores, etc.)
                    // .listStyle(.plain)
                }
            }
            .navigationTitle("Hoy (\(Date(), formatter: DayLogViewModel.dateFormatter))") // Título con la fecha
            // Opcional: Añadir un DatePicker para cambiar de día
            // .toolbar { ToolbarItem(placement: .navigationBarLeading) { DatePicker(...) } }
            .toolbar {
                // Botón para añadir nueva actividad
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activityToEdit = nil // Asegura que estamos añadiendo, no editando
                        showingAddEditSheet = true
                    } label: {
                        Label("Añadir Actividad", systemImage: "plus.circle.fill")
                    }
                }
                // Opcional: Botón Editar para el modo de edición de la lista (si no usas onTapGesture/onDelete)
                // ToolbarItem(placement: .navigationBarLeading) { EditButton() }
            }
            // Presenta la vista modal (sheet) para añadir o editar
            .sheet(isPresented: $showingAddEditSheet) {
                // La vista necesita el viewModel y opcionalmente la actividad a editar
                AddEditActivityView(viewModel: viewModel, activityToEdit: activityToEdit)
            }
        }
        // Para iOS 16+ podrías usar NavigationStack en lugar de NavigationView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}