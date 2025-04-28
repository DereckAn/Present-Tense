import Foundation
import Combine // O @Observable

// @Observable // Si usas iOS 17+
class DayLogViewModel: ObservableObject {

    @Published var activities: [ActivityLog] = []
    // Hacemos que la fecha seleccionada sea @Published para que la vista pueda reaccionar
    @Published var selectedDate: Date = Date() {
        // Opcional: Podrías añadir lógica aquí si algo debe pasar *inmediatamente*
        // cuando cambia la fecha, aunque generalmente el filtrado se hace
        // en la propiedad computada o en la vista.
        didSet {
            print("Selected date changed to: \(selectedDate)")
            // Aquí podrías disparar una carga de datos si fuera necesario para esa fecha
        }
    }

    // La propiedad computada ahora usa la @Published selectedDate
    var activitiesForSelectedDate: [ActivityLog] {
        let calendar = Calendar.current
        // Filtra del array 'activities' completo
        return activities.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
                            .sorted { $0.timestamp < $1.timestamp } // Asegura orden dentro del día
    }

    // Mantenemos los formateadores
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // "h:mm a" para AM/PM
        return formatter
    }()

    // Formateador para el encabezado (Día número) - Ejemplo: "28"
    static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    // Formateador para el encabezado (Mes y Año) - Ejemplo: "April 2025"
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // Mes completo y año
        return formatter
    }()

     // Formateador para el encabezado (Año solo) - Ejemplo: "2025"
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

     // Formateador para el encabezado (Mes solo) - Ejemplo: "April"
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()


    // Formateador para abreviatura del día de la semana (Ej: "MON")
     static let shortDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Ejemplo: "Mon", "Tue"
        // formatter.locale = Locale(identifier: "es_ES") // Si quieres español: "lun.", "mar."
        return formatter
    }()


    init() {
        loadSampleData() // Cargar datos iniciales (o cargar desde persistencia)
        // Ya no necesitamos ordenar aquí si activitiesForSelectedDate ordena
    }

    // --- Funciones CRUD (Sin cambios) ---
    func addActivity(description: String, timestamp: Date = Date()) {
         guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
         // Asegúrate de que la nueva actividad use la *fecha* seleccionada pero la *hora* actual (o una elegida)
         let calendar = Calendar.current
         var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
         let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timestamp) // Usa la hora de 'timestamp'
         components.hour = timeComponents.hour
         components.minute = timeComponents.minute
         components.second = timeComponents.second

         let finalTimestamp = calendar.date(from: components) ?? timestamp // Fallback a la hora original

         let newActivity = ActivityLog(timestamp: finalTimestamp, description: description)
         activities.append(newActivity)
         // La vista se actualizará porque 'activities' es @Published y activitiesForSelectedDate se recalculará
         // save() // Llamarías a tu función de guardado aquí
    }

     func updateActivity(activity: ActivityLog) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index] = activity
         // save()
    }

    func deleteActivity(at offsets: IndexSet) {
        // Necesitamos mapear los offsets de la lista filtrada a la lista completa
        let filteredActivities = activitiesForSelectedDate
        let idsToDelete = offsets.map { filteredActivities[$0].id }
        activities.removeAll { idsToDelete.contains($0.id) }
        // save()
    }

     // Helper para borrar por objeto (usado si no es por swipe)
     func deleteActivity(activity: ActivityLog) {
        activities.removeAll { $0.id == activity.id }
         // save()
     }


    // --- Lógica de Fechas para la Semana ---
    func getWeekDays(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }

        var weekDays: [Date] = []
        var currentDate = weekInterval.start
        let endDate = weekInterval.end

        while currentDate < endDate {
            weekDays.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }
        return weekDays
    }

    // Días de la semana basados en la selectedDate
    var currentWeekDays: [Date] {
        getWeekDays(for: selectedDate)
    }


    // --- Datos de Muestra ---
    private func loadSampleData() {
        // Datos de muestra para hoy y quizás otros días para probar
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

         activities = [
            // Hoy
            ActivityLog(timestamp: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today)!, description: "Despertar"),
            ActivityLog(timestamp: calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today)!, description: "Desayuno"),
            ActivityLog(timestamp: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!, description: "Trabajo - Email"),
            ActivityLog(timestamp: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: today)!, description: "Reunión de equipo"),
            // Ayer
            ActivityLog(timestamp: calendar.date(bySettingHour: 22, minute: 30, second: 0, of: yesterday)!, description: "Leer"),
            ActivityLog(timestamp: calendar.date(bySettingHour: 23, minute: 15, second: 0, of: yesterday)!, description: "Dormir")
        ]
    }

    // --- Lógica de Guardado/Carga (Placeholder) ---
    // func save() { /* Implementar guardado (SwiftData, CoreData, File) */ }
    // func load() { /* Implementar carga */ }
}
