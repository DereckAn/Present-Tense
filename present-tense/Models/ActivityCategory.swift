import Foundation
import SwiftUI

enum ActivityCategory: String, CaseIterable, Identifiable, Codable {
    case work = "work"
    case sleep = "sleep"
    case food = "food"
    case exercise = "exercise"
    case social = "social"
    case hobby = "hobby"
    case transport = "transport"
    case health = "health"
    case education = "education"
    case entertainment = "entertainment"
    case household = "household"
    case personal = "personal"
    case other = "other"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .work: return "Trabajo"
        case .sleep: return "Dormir"
        case .food: return "Comida"
        case .exercise: return "Ejercicio"
        case .social: return "Social"
        case .hobby: return "Hobby"
        case .transport: return "Transporte"
        case .health: return "Salud"
        case .education: return "Educación"
        case .entertainment: return "Entretenimiento"
        case .household: return "Hogar"
        case .personal: return "Personal"
        case .other: return "Otro"
        }
    }
    
    var iconName: String {
        switch self {
        case .work: return "briefcase.fill"
        case .sleep: return "bed.double.fill"
        case .food: return "fork.knife"
        case .exercise: return "figure.run"
        case .social: return "person.2.fill"
        case .hobby: return "gamecontroller.fill"
        case .transport: return "car.fill"
        case .health: return "cross.fill"
        case .education: return "book.fill"
        case .entertainment: return "tv.fill"
        case .household: return "house.fill"
        case .personal: return "person.fill"
        case .other: return "circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .sleep: return .purple
        case .food: return .orange
        case .exercise: return .green
        case .social: return .pink
        case .hobby: return .yellow
        case .transport: return .gray
        case .health: return .red
        case .education: return .indigo
        case .entertainment: return .mint
        case .household: return .brown
        case .personal: return .cyan
        case .other: return .secondary
        }
    }
}