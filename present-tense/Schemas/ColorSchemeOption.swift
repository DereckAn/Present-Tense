//
//  ColorSchemeOption.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/29/25.
//


import SwiftUI

// Enum para representar las opciones de esquema de color
// RawValue = Int para poder guardarlo fácilmente en AppStorage
// CaseIterable para poder iterar sobre él en el Picker
enum ColorSchemeOption: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    var id: Int { self.rawValue }

    // Texto descriptivo para mostrar en el Picker
    var displayName: String {
        switch self {
        case .system: return "Automático (Sistema)"
        case .light: return "Claro"
        case .dark: return "Oscuro"
        }
    }

    // Convierte nuestra opción al tipo que entiende SwiftUI
    func toSwiftUIScheme() -> ColorScheme? {
        switch self {
        case .system: return nil // nil significa seguir al sistema
        case .light: return .light
        case .dark: return .dark
        }
    }
}