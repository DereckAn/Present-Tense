//
//  DayLogViewModel.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import Foundation
import Combine // O @Observable directamente si usas iOS 17+

// Para iOS 17+ puedes usar @Observable
// @Observable
// class DayLogViewModel { ... }

// Para versiones anteriores (o si prefieres Combine explícito):
class DayLogViewModel: ObservableObject {

    @Published var activities: [ActivityLog] = [] // La lista de actividades que la vista observará
    @Published var selectedDate: Date = Date() // Podrías añadir esto si quieres ver días pasados

    // Para este ejemplo, cargamos datos de muestra
    init() {
        loadSampleData()
        sortActivities()
    }

    // --- Funciones CRUD (Crear, Leer, Actualizar, Borrar) ---

    func addActivity(description: String, timestamp: Date = Date()) {
        // Validación simple
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Error: La descripción no puede estar vacía.")
            return // O manejar el error de otra forma (mostrar alerta)
        }
        let newActivity = ActivityLog(timestamp: timestamp, description: description)
        activities.append(newActivity)
        sortActivities() // Mantener el orden
        // Aquí iría la lógica para guardar permanentemente (Core Data, SwiftData, etc.)
    }

    func updateActivity(activity: ActivityLog) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else {
            print("Error: Actividad no encontrada para actualizar.")
            return
        }
        activities[index] = activity
        sortActivities() // Reordenar por si cambió la hora
        // Aquí iría la lógica para guardar permanentemente
    }

    func deleteActivity(at offsets: IndexSet) {
        activities.remove(atOffsets: offsets)
        // Aquí iría la lógica para guardar permanentemente
    }

     func deleteActivity(activity: ActivityLog) {
        activities.removeAll { $0.id == activity.id }
        // Aquí iría la lógica para guardar permanentemente
    }


    // --- Lógica Auxiliar ---

    private func sortActivities() {
        // Ordena las actividades por fecha/hora, de más reciente a más antigua (o viceversa)
        activities.sort { $0.timestamp < $1.timestamp } // Más antigua primero
        // activities.sort { $0.timestamp > $1.timestamp } // Más reciente primero
    }

    // Filtra las actividades para mostrar solo las del día seleccionado
    // (Útil si implementas navegación entre días)
    var activitiesForSelectedDate: [ActivityLog] {
        let calendar = Calendar.current
        return activities.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }

    // --- Datos de Muestra (solo para desarrollo) ---
    private func loadSampleData() {
        // Puedes crear fechas específicas si quieres probar mejor
        let calendar = Calendar.current
        let now = Date()
        let components = DateComponents(calendar: calendar, hour: 6, minute: 0)
        let sixAM = calendar.date(byAdding: components, to: calendar.startOfDay(for: now)) ?? now

        activities = [
            ActivityLog(timestamp: sixAM, description: "Despertar"),
            ActivityLog(timestamp: calendar.date(byAdding: .hour, value: 1, to: sixAM)!, description: "Desayuno"),
            ActivityLog(timestamp: calendar.date(byAdding: .hour, value: 3, to: sixAM)!, description: "Trabajo - Email"),
            ActivityLog(timestamp: calendar.date(byAdding: .minute, value: 90, to: calendar.date(byAdding: .hour, value: 3, to: sixAM)!)!, description: "Reunión de equipo")
        ]
    }

    // --- Formateadores (Helpers para la Vista) ---
    // Es bueno tenerlos aquí para mantener la lógica de formato fuera de la Vista
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Formato 24h (ej: 09:15) o "h:mm a" (ej: 9:15 AM)
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // "15 jun 2024"
        formatter.timeStyle = .none
        return formatter
    }()
}