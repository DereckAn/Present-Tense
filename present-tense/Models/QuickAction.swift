import Foundation
import SwiftUI

struct QuickAction: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var category: ActivityCategory
    var isDefault: Bool
    
    init(id: UUID = UUID(), title: String, category: ActivityCategory, isDefault: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.isDefault = isDefault
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: QuickAction, rhs: QuickAction) -> Bool {
        lhs.id == rhs.id
    }
    
    // Default quick actions
    static let defaultActions: [QuickAction] = [
        QuickAction(title: "Trabajar", category: .work, isDefault: true),
        QuickAction(title: "Dormir", category: .sleep, isDefault: true),
        QuickAction(title: "Comer", category: .food, isDefault: true),
        QuickAction(title: "Ejercicio", category: .exercise, isDefault: true),
        QuickAction(title: "Socializar", category: .social, isDefault: true),
        QuickAction(title: "Hobby", category: .hobby, isDefault: true)
    ]
}