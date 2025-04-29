import Foundation
import SwiftUI

// En ActivityLog.swift (Opcional)
struct ActivityLog: Identifiable, Codable, Hashable {
    let id: UUID
    var timestamp: Date
    var description: String
    var iconName: String = "pencil" // Nombre del icono SF Symbol por defecto
    var iconColor: Color = .pink    // Color del icono por defecto (Necesitarás importar SwiftUI o manejar colores de otra forma si no quieres dependencia de UI en el Modelo)

    // Nota: Guardar un 'Color' directamente con Codable puede ser complejo.
    // A menudo se guarda el nombre del color (String) o sus componentes RGBA.
    // Por ahora, dejaremos 'Color' para simplificar, asumiendo que no guardas/cargas todavía.

    // Inicializador actualizado
    init(id: UUID = UUID(), timestamp: Date = Date(), description: String, iconName: String = "pencil", iconColor: Color = .pink) {
        self.id = id
        self.timestamp = timestamp
        self.description = description
        self.iconName = iconName // Asignar en el init
        self.iconColor = iconColor // Asignar en el init
    }

     // Conformancia a Codable (simplificada, necesitaría manejo especial para Color)
     enum CodingKeys: String, CodingKey {
         case id, timestamp, description, iconName // No codificar iconColor directamente así
     }

    // Conformancia a Hashable (si se necesita)
     func hash(into hasher: inout Hasher) {
        hasher.combine(id)
     }
     static func == (lhs: ActivityLog, rhs: ActivityLog) -> Bool {
         lhs.id == rhs.id
     }
}
