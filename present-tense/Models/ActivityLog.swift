import Foundation

struct ActivityLog: Identifiable, Codable, Hashable {
    let id: UUID         // Identificador único para cada entrada
    var timestamp: Date  // La hora y fecha exactas de la actividad
    var description: String // Lo que el usuario estaba haciendo

    // Inicializador para crear nuevas entradas
    init(id: UUID = UUID(), timestamp: Date = Date(), description: String) {
        self.id = id
        self.timestamp = timestamp
        self.description = description
    }
}
