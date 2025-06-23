import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var selectedTimeRange: TimeRange = .week
    @Published var selectedCategory: ActivityCategory? = nil
    @Published var isLoading: Bool = false
    
    private var activityViewModel: ActivityViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(activityViewModel: ActivityViewModel = .shared) {
        self.activityViewModel = activityViewModel
        
        activityViewModel.$activities
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Time Range Statistics
    var currentDateRange: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return DateInterval(start: startOfDay, end: endOfDay)
            
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            return DateInterval(start: startOfWeek, end: endOfWeek)
            
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return DateInterval(start: startOfMonth, end: endOfMonth)
            
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
            return DateInterval(start: startOfYear, end: endOfYear)
        }
    }
    
    var activitiesInRange: [Activity] {
        let range = currentDateRange
        return activityViewModel.activities.filter { activity in
            range.contains(activity.startTime)
        }
    }
    
    // MARK: - Category Statistics
    var categoryStats: [CategoryStat] {
        let categories = ActivityCategory.allCases
        
        return categories.compactMap { category in
            let categoryActivities = activitiesInRange.filter { $0.category == category }
            guard !categoryActivities.isEmpty else { return nil }
            
            let totalTime = categoryActivities.compactMap { activity in
                activity.endTime != nil ? activity.duration : nil
            }.reduce(0, +)
            
            let count = categoryActivities.count
            let averageTime = count > 0 ? totalTime / Double(count) : 0
            
            return CategoryStat(
                category: category,
                totalTime: totalTime,
                count: count,
                averageTime: averageTime,
                percentage: 0 // Se calculará después
            )
        }.sorted { $0.totalTime > $1.totalTime }
    }
    
    var categoryStatsWithPercentages: [CategoryStat] {
        let stats = categoryStats
        let totalTime = stats.reduce(0) { $0 + $1.totalTime }
        
        return stats.map { stat in
            CategoryStat(
                category: stat.category,
                totalTime: stat.totalTime,
                count: stat.count,
                averageTime: stat.averageTime,
                percentage: totalTime > 0 ? (stat.totalTime / totalTime) * 100 : 0
            )
        }
    }
    
    // MARK: - Daily Patterns
    var dailyPattern: [HourStat] {
        var hourStats: [Int: TimeInterval] = [:]
        
        for activity in activitiesInRange {
            guard let endTime = activity.endTime else { continue }
            
            let calendar = Calendar.current
            let startHour = calendar.component(.hour, from: activity.startTime)
            let endHour = calendar.component(.hour, from: endTime)
            
            for hour in startHour...endHour {
                hourStats[hour, default: 0] += activity.duration / Double(endHour - startHour + 1)
            }
        }
        
        return (0..<24).map { hour in
            HourStat(hour: hour, totalTime: hourStats[hour] ?? 0)
        }
    }
    
    // MARK: - Weekly Patterns
    var weeklyPattern: [WeekdayStat] {
        var weekdayStats: [Int: TimeInterval] = [:]
        
        for activity in activitiesInRange {
            guard let endTime = activity.endTime else { continue }
            
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: activity.startTime)
            weekdayStats[weekday, default: 0] += activity.duration
        }
        
        return (1...7).map { weekday in
            let weekdayName = Calendar.current.weekdaySymbols[weekday - 1]
            return WeekdayStat(
                weekday: weekday,
                weekdayName: weekdayName,
                totalTime: weekdayStats[weekday] ?? 0
            )
        }
    }
    
    // MARK: - Summary Stats
    var totalTimeInRange: TimeInterval {
        activitiesInRange.compactMap { activity in
            activity.endTime != nil ? activity.duration : nil
        }.reduce(0, +)
    }
    
    var totalActivitiesInRange: Int {
        activitiesInRange.count
    }
    
    var averageActivityDuration: TimeInterval {
        let completedActivities = activitiesInRange.filter { $0.endTime != nil }
        guard !completedActivities.isEmpty else { return 0 }
        
        return totalTimeInRange / Double(completedActivities.count)
    }
    
    var mostActiveDay: String? {
        let dayStats = weeklyPattern.max { $0.totalTime < $1.totalTime }
        return dayStats?.weekdayName
    }
    
    var mostUsedCategory: ActivityCategory? {
        categoryStats.first?.category
    }
}

// MARK: - Supporting Types
enum TimeRange: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .day: return "Hoy"
        case .week: return "Esta semana"
        case .month: return "Este mes"
        case .year: return "Este año"
        }
    }
}

struct CategoryStat {
    let category: ActivityCategory
    let totalTime: TimeInterval
    let count: Int
    let averageTime: TimeInterval
    let percentage: Double
    
    var formattedTotalTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = Int(totalTime) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedAverageTime: String {
        let hours = Int(averageTime) / 3600
        let minutes = Int(averageTime) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedPercentage: String {
        return String(format: "%.1f%%", percentage)
    }
}

struct HourStat {
    let hour: Int
    let totalTime: TimeInterval
    
    var formattedHour: String {
        return String(format: "%02d:00", hour)
    }
    
    var formattedTime: String {
        let minutes = Int(totalTime) / 60
        return "\(minutes)m"
    }
}

struct WeekdayStat {
    let weekday: Int
    let weekdayName: String
    let totalTime: TimeInterval
    
    var formattedTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = Int(totalTime) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
}