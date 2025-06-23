import Foundation
import SwiftUI

struct Activity: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var startTime: Date
    var endTime: Date?
    var category: ActivityCategory
    var isRecurring: Bool
    var recurringPattern: RecurringPattern?
    var tags: [String]
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        category: ActivityCategory = .other,
        isRecurring: Bool = false,
        recurringPattern: RecurringPattern? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.isRecurring = isRecurring
        self.recurringPattern = recurringPattern
        self.tags = tags
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var dayIdentifier: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: startTime)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}

enum RecurringPattern: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case weekdays = "weekdays"
    case weekends = "weekends"
    
    var displayName: String {
        switch self {
        case .daily: return "Diario"
        case .weekly: return "Semanal"
        case .monthly: return "Mensual"
        case .weekdays: return "Entre semana"
        case .weekends: return "Fines de semana"
        }
    }
}