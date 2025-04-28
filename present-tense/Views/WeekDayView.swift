//
//  WeekDayView.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

struct WeekDayView: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void // Closure para manejar el tap

    private var dayAbbreviation: String {
        date.formatted(Date.FormatStyle().weekday(.abbreviated)) // "Mon", "Tue"
        // O usar nuestro formateador: DayLogViewModel.shortDayFormatter.string(from: date).uppercased()
    }

    private var dayNumber: String {
        DayLogViewModel.dayNumberFormatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(dayAbbreviation)
                .font(.caption)
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity) // Para centrar texto corto como "Tue"

            Text(dayNumber)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 40, height: 40) // Tamaño fijo para el círculo/fondo
                .background {
                    if isSelected {
                        Circle().fill(Color.blue) // Círculo azul si está seleccionado
                    } else if Calendar.current.isDateInToday(date) {
                         // Opcional: Marcar el día de hoy de forma diferente si no está seleccionado
                        Circle().fill(Color.gray.opacity(0.2))
                    }
                }
        }
        .padding(.vertical, 5) // Espacio arriba/abajo del Vstack
        .onTapGesture {
            onTap() // Ejecuta la acción al tocar
        }
    }
}

// Preview para WeekDayView
#Preview {
    HStack {
        WeekDayView(date: Date(), isSelected: true) {}
        WeekDayView(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, isSelected: false) {}
         WeekDayView(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isSelected: false) {}
    }
    .padding()
}