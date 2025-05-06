//
//  AppTab.swift
//  present-tense
//
//  Created by Dereck Ángeles on 5/6/25.
//


// En un archivo separado como AppTab.swift o dentro de tu archivo principal de la App

import SwiftUI

enum AppTab: CaseIterable, Identifiable { // CaseIterable e Identifiable para el Picker si lo necesitas
    case timeline, calendar, diary, plan, settings // Eliminé "Now" por ahora, puedes añadirlo si lo necesitas

    var id: Self { self } // Necesario para Identifiable si usas el propio enum como ID

    // Propiedades para definir el texto y el icono de cada tab
    var title: String {
        switch self {
        case .timeline: return "Timeline"
        case .calendar: return "Calendar"
        case .diary:    return "Diary"
        case .plan:     return "Plan"
        case .settings: return "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .timeline: return "list.bullet" // Cambiado para consistencia con diseño anterior
        case .calendar: return "calendar"
        case .diary:    return "book.closed" // Cambiado para consistencia
        case .plan:     return "chart.bar" // O "checklist"
        case .settings: return "gear"
        }
    }
}