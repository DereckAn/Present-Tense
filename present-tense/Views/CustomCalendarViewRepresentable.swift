//
//  CustomCalendarViewRepresentable.swift
//  present-tense
//
//  Created by Dereck Ángeles on 5/6/25.
//


import SwiftUI
import UIKit // Necesario para UICalendarView

@available(iOS 16.0, *)
struct CustomCalendarViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: DayLogViewModel // Para obtener datos de actividades
    @Binding var selectedDate: Date?             // Para comunicar la fecha seleccionada
    // Binding para el intervalo del mes visible (opcional, pero útil)
    @Binding var visibleMonthInterval: DateInterval

    // Delegado para manejar interacciones y decoración
    private let delegate: UICalendarViewDelegate

    // Inicializador
    init(viewModel: ObservedObject<DayLogViewModel>, selectedDate: Binding<Date?>, visibleMonthInterval: Binding<DateInterval>) {
        _viewModel = viewModel
        _selectedDate = selectedDate
        _visibleMonthInterval = visibleMonthInterval
        // Creamos e inicializamos el delegado aquí
        self.delegate = CalendarDelegate(
            viewModel: viewModel.wrappedValue, // Pasamos el DayLogViewModel
            selectedDate: selectedDate,
            visibleMonthInterval: visibleMonthInterval
        )
    }

    // --- UIViewRepresentable Protocol Methods ---

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.delegate = delegate // Asigna nuestro delegado personalizado
        calendarView.calendar = Calendar.current // Usa el calendario del sistema
        calendarView.locale = Locale.current   // Usa el locale del sistema

        // Configura el rango de fechas visibles si es necesario (opcional)
        // let gregorianCalendar = Calendar(identifier: .gregorian)
        // let fromDate = gregorianCalendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        // let toDate = gregorianCalendar.date(from: DateComponents(year: 2100, month: 12, day: 31))!
        // calendarView.availableDateRange = DateInterval(start: fromDate, end: toDate)

        // Establecer la fecha visible inicial (el mes actual)
        // Esta llamada puede que no sea necesaria si el delegado maneja bien el visibleMonthInterval
        let selection = UICalendarSelectionSingleDate(delegate: delegate as? UICalendarSelectionSingleDateDelegate)
        calendarView.selectionBehavior = selection

        // Informar al delegado sobre el intervalo visible inicial
        // Esto es un poco hacky, idealmente el UICalendarView lo haría.
        DispatchQueue.main.async {
            if let currentMonth = Calendar.current.dateInterval(of: .month, for: Date()) {
                self.delegate.calendarView?(calendarView, didChangeVisibleDateComponentsFrom: Calendar.current.dateComponents([.year, .month, .day], from: currentMonth.start))
            }
        }

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Actualiza la vista de UIKit si los datos de SwiftUI cambian.
        // Por ejemplo, si necesitas recargar decoraciones porque las actividades cambiaron.
        // A menudo, el delegado se encarga de esto, pero puedes forzarlo aquí.
        // uiView.reloadDecorations(forDateComponents: <#T##[DateComponents]#>, animated: <#T##Bool#>)
        // Si la selectedDate cambia desde SwiftUI, actualiza la selección en UICalendarView
        if let swiftUIDate = selectedDate {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: swiftUIDate)
            if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
                 // Solo actualiza si la selección del UICalendarView es diferente
                if selection.selectedDate != dateComponents {
                    selection.setSelected(dateComponents, animated: true)
                }
            }
        } else {
            if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
                selection.setSelected(nil, animated: true)
            }
        }
    }

    // --- Coordinator (Opcional aquí, ya que el Delegado es una clase separada) ---
    // func makeCoordinator() -> Coordinator {
    //     Coordinator(self)
    // }
    // class Coordinator: NSObject { ... }
}

// --- Delegado Personalizado para UICalendarView ---
@available(iOS 16.0, *)
class CalendarDelegate: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    var viewModel: DayLogViewModel
    @Binding var selectedDate: Date?
    @Binding var visibleMonthInterval: DateInterval
    private var datesWithActivitiesCache: Set<DateComponents> = [] // Caché para optimizar

    init(viewModel: DayLogViewModel, selectedDate: Binding<Date?>, visibleMonthInterval: Binding<DateInterval>) {
        self.viewModel = viewModel
        _selectedDate = selectedDate
        _visibleMonthInterval = visibleMonthInterval
        super.init()
        // Actualizar caché inicial
        self.updateActivityCache(for: visibleMonthInterval.wrappedValue)
    }

    // --- UICalendarSelectionSingleDateDelegate ---
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selectedDate = dateComponents?.date // Actualiza el @Binding de SwiftUI
    }

    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true // Permite seleccionar cualquier fecha
    }


    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        // El mes visible ha cambiado, actualiza el binding y el caché de actividades

        // Obtener el intervalo del mes visible actual
        guard let currentMonthInterval = calendarView.calendar.dateInterval(of: .month, for: calendarView.visibleDateComponents.date ?? Date()) else {
            return // No se pudo obtener el intervalo, salir
        }

        // Solo actualiza si realmente cambió para evitar bucles y trabajo innecesario
        if visibleMonthInterval != currentMonthInterval {
            visibleMonthInterval = currentMonthInterval // Actualiza el @Binding de SwiftUI
            updateActivityCache(for: currentMonthInterval) // Actualiza el caché con el nuevo intervalo

            // Recarga las decoraciones para todo el nuevo mes visible
            // Crear un array de DateComponents para todas las fechas en el nuevo intervalo visible
            var datesToReload: [DateComponents] = []
            var dateIterator = currentMonthInterval.start
            let calendar = calendarView.calendar
            while dateIterator <= currentMonthInterval.end {
                datesToReload.append(calendar.dateComponents([.year, .month, .day], from: dateIterator))
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: dateIterator) {
                    dateIterator = nextDay
                } else {
                    break // Salir si no se puede obtener el siguiente día
                }
            }
            if !datesToReload.isEmpty {
                calendarView.reloadDecorations(forDateComponents: datesToReload, animated: true)
            }
        }
    }
    
    private func dateComponentsForInterval(_ interval: DateInterval) -> [DateComponents] {
        var componentsArray: [DateComponents] = []
        var currentDate = interval.start
        let calendar = Calendar.current
        while currentDate <= interval.end {
            componentsArray.append(calendar.dateComponents([.year, .month, .day], from: currentDate))
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            } else {
                break
            }
        }
        return componentsArray
    }


    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // Comprueba si este día tiene actividades usando el caché
        if datesWithActivitiesCache.contains(dateComponents) {
            // Devuelve una decoración (ej. un punto)
            return .default(color: .orange, size: .small) // Puedes usar .image, .customView
        }
        return nil // Sin decoración
    }

    // Helper para actualizar el caché de actividades
    private func updateActivityCache(for interval: DateInterval) {
        // Asegúrate de que el intervalo sea válido
        guard interval.duration > 0 else {
            datesWithActivitiesCache = []
            return
        }
        datesWithActivitiesCache = viewModel.datesWithActivities(in: interval)
    }
}
