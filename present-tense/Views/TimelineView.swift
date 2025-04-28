//
//  TimelineView.swift
//  present-tense
//
//  Created by Dereck Ángeles on 4/28/25.
//


import SwiftUI

struct TimelineView: View {
    // Necesita observar el ViewModel para obtener datos y la fecha seleccionada
    @ObservedObject var viewModel: DayLogViewModel
    // Necesita una forma de decirle a ContentView que muestre la sheet de edición
    let onEditActivity: (ActivityLog) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 1. Encabezado con Fecha Personalizada (Ahora DENTRO de TimelineView)
            DateHeaderView(date: viewModel.selectedDate)
                .padding(.top)
                .padding(.horizontal)

            // 2. Selector de Semana Horizontal (Ahora DENTRO de TimelineView)
            WeekSelectorView(
                selectedDate: $viewModel.selectedDate, // Binding directo al ViewModel
                weekDays: viewModel.currentWeekDays
            )
            .padding(.vertical, 10)

            Divider()

            // 3. Lista de Actividades (Podría ser ActivityListView o directamente aquí)
            if viewModel.activitiesForSelectedDate.isEmpty {
                Text("No hay actividades registradas para este día.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Centrar
            } else {
                List {
                    ForEach(viewModel.activitiesForSelectedDate) { activity in
                        ActivityRowView(activity: activity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onEditActivity(activity) // Llama al closure pasado desde ContentView
                            }
                            // .listRowSeparator(.hidden) // Opcional
                            // .listRowInsets(EdgeInsets()) // Opcional
                    }
                    .onDelete(perform: viewModel.deleteActivity) // Swipe to delete
                }
                .listStyle(.plain) // Estilo limpio
            }
        }
    }
}

// Puedes mantener las definiciones de DateHeaderView y WeekSelectorView aquí
// o moverlas a sus propios archivos si lo prefieres.

// Vista para el Encabezado de Fecha
struct DateHeaderView: View {
    // ... (código igual que antes)
    let date: Date
    var dayColor: Color = .blue
    var yearColor: Color = .green

    var body: some View {
        HStack {
            Text(date, formatter: DayLogViewModel.dayNumberFormatter)
                .font(.largeTitle).bold()
                .foregroundColor(dayColor)
            + Text(" ")
            + Text(date, formatter: DayLogViewModel.monthFormatter)
                .font(.largeTitle).bold()
            + Text(" ")
            + Text(date, formatter: DayLogViewModel.yearFormatter)
                .font(.largeTitle).bold()
                .foregroundColor(yearColor)
            Spacer()
        }.accessibilityLabel(Text(date, style: .date)) // Mejora accesibilidad
    }
}

// Vista para el Selector de Semana
struct WeekSelectorView: View {
    // ... (código igual que antes)
    @Binding var selectedDate: Date
    let weekDays: [Date]
    let calendar = Calendar.current

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(weekDays, id: \.self) { day in
                    WeekDayView(
                        date: day,
                        isSelected: calendar.isDate(day, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = day
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


// NO incluyas ActivityListView aquí si la defines en su propio archivo.
// Si no, puedes incluirla aquí.

// Preview para TimelineView (Necesita un ViewModel de muestra)
#Preview {
    TimelineView(viewModel: DayLogViewModel()) { activity in
        print("Edit activity: \(activity.description)")
    }
}