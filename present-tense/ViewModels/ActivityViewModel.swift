import Foundation
import Combine

class ActivityViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var currentActivity: Activity?
    @Published var selectedDate: Date = Date()
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = ActivityViewModel()
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Activity Management
    func addActivity(_ activity: Activity) {
        activities.append(activity)
        saveActivities()
    }
    
    func updateActivity(_ activity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities[index] = activity
            saveActivities()
        }
    }
    
    func deleteActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        saveActivities()
    }
    
    func startActivity(title: String, category: ActivityCategory, description: String? = nil) {
        stopCurrentActivity()
        
        let newActivity = Activity(
            title: title,
            description: description,
            startTime: Date(),
            category: category
        )
        
        currentActivity = newActivity
        addActivity(newActivity)
    }
    
    func stopCurrentActivity() {
        guard let current = currentActivity,
              let index = activities.firstIndex(where: { $0.id == current.id }) else {
            return
        }
        
        activities[index].endTime = Date()
        currentActivity = nil
        saveActivities()
    }
    
    // MARK: - Data Filtering
    func activitiesForDate(_ date: Date) -> [Activity] {
        let calendar = Calendar.current
        return activities.filter { activity in
            calendar.isDate(activity.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    func activitiesForDateRange(from startDate: Date, to endDate: Date) -> [Activity] {
        return activities.filter { activity in
            activity.startTime >= startDate && activity.startTime <= endDate
        }.sorted { $0.startTime < $1.startTime }
    }
    
    func activitiesForCategory(_ category: ActivityCategory) -> [Activity] {
        return activities.filter { $0.category == category }
    }
    
    var activitiesForSelectedDate: [Activity] {
        activitiesForDate(selectedDate)
    }
    
    // MARK: - Statistics
    func totalTimeForCategory(_ category: ActivityCategory, in dateRange: DateInterval? = nil) -> TimeInterval {
        let relevantActivities: [Activity]
        
        if let dateRange = dateRange {
            relevantActivities = activities.filter { activity in
                dateRange.contains(activity.startTime) && activity.category == category
            }
        } else {
            relevantActivities = activities.filter { $0.category == category }
        }
        
        return relevantActivities.compactMap { activity in
            activity.endTime != nil ? activity.duration : nil
        }.reduce(0, +)
    }
    
    func averageDailyTimeForCategory(_ category: ActivityCategory, days: Int = 7) -> TimeInterval {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let dateRange = DateInterval(start: startDate, end: endDate)
        
        let totalTime = totalTimeForCategory(category, in: dateRange)
        return totalTime / Double(days)
    }
    
    func daysWithActivities() -> Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return Set(activities.map { formatter.string(from: $0.startTime) })
    }
    
    // MARK: - Persistence
    private func saveActivities() {
        do {
            let data = try JSONEncoder().encode(activities)
            UserDefaults.standard.set(data, forKey: "SavedActivities")
        } catch {
            print("Error saving activities: \(error)")
        }
    }
    
    private func loadActivities() {
        guard let data = UserDefaults.standard.data(forKey: "SavedActivities") else {
            return
        }
        
        do {
            activities = try JSONDecoder().decode([Activity].self, from: data)
        } catch {
            print("Error loading activities: \(error)")
        }
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        
        activities = [
            Activity(
                title: "Trabajo - Reunión de equipo",
                description: "Reunión semanal con el equipo de desarrollo",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                endTime: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!,
                category: .work,
                isRecurring: true,
                recurringPattern: .weekly
            ),
            Activity(
                title: "Desayuno",
                startTime: calendar.date(bySettingHour: 7, minute: 30, second: 0, of: now)!,
                endTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!,
                category: .food,
                isRecurring: true,
                recurringPattern: .daily
            ),
            Activity(
                title: "Ejercicio - Correr",
                description: "Corrida matutina en el parque",
                startTime: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: yesterday)!,
                endTime: calendar.date(bySettingHour: 7, minute: 0, second: 0, of: yesterday)!,
                category: .exercise
            ),
            Activity(
                title: "Leer - Libro de programación",
                startTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: twoDaysAgo)!,
                endTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: twoDaysAgo)!,
                category: .education
            )
        ]
    }
}