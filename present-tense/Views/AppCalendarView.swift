import SwiftUI

@available(iOS 16.0, *)
struct AppCalendarView: View {
    @ObservedObject var viewModel: DayLogViewModel
    @State private var selectedDate: Date? = nil // Ahora es un Date opcional
    @State private var showingDayActivitiesSheet = false
    // Estado para el intervalo del mes visible (se actualiza desde el Representable)
    @State private var visibleMonthInterval: DateInterval = Calendar.current.dateInterval(of: .month, for: Date()) ?? DateInterval()


    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                // Mostrar el mes y año actual
                Text(visibleMonthInterval.start, formatter: DayLogViewModel.monthYearFormatter)
                    .font(.title2.bold())
                    .padding(.horizontal)

                CustomCalendarViewRepresentable(
                    viewModel: _viewModel, // Pasa el ObservedObject
                    selectedDate: $selectedDate,
                    visibleMonthInterval: $visibleMonthInterval
                )
                // .frame(height: 400) // Ajusta la altura si es necesario

                Spacer()
            }
            .navigationTitle("Calendario")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedDate) { newDate in
                // Cuando selectedDate cambia (desde UICalendarView), decide si mostrar la sheet
                if let date = newDate, !viewModel.activities(for: date).isEmpty {
                    showingDayActivitiesSheet = true
                } else if newDate != nil {
                     // Opcional: mostrar sheet aunque esté vacía
                     // showingDayActivitiesSheet = true
                    print("Día seleccionado sin actividades: \(String(describing: newDate))")
                }
            }
            .sheet(isPresented: $showingDayActivitiesSheet) {
                if let date = selectedDate {
                    DayActivitiesListView(date: date, viewModel: viewModel)
                }
            }
        }
    }
}

// Vista auxiliar para mostrar la lista de actividades de un día específico
// Presentada en una sheet
@available(iOS 16.0, macOS 13.0, *)
struct DayActivitiesListView: View {
    let date: Date
    @ObservedObject var viewModel: DayLogViewModel
    @Environment(\.dismiss) var dismiss

    private var activitiesForDay: [ActivityLog] {
        viewModel.activities(for: date)
    }

    var body: some View {
        NavigationView { // Para tener título y botón de cerrar en la sheet
            VStack {
                if activitiesForDay.isEmpty {
                    Text("No hay actividades registradas para el \(date, style: .date).")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(activitiesForDay) { activity in
                            // Usamos la ActivityRowView que ya tienes
                            ActivityRowView(activity: activity)
                        }
                    }
                }
            }
            .navigationTitle("Actividades del \(date, formatter: DayLogViewModel.dateFormatter)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview
@available(iOS 16.0, *)
#Preview {
    let previewViewModel = DayLogViewModel()
    let calendar = Calendar.current
    if let today = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()),
       let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
        previewViewModel.addActivity(description: "Reunión", timestamp: today)
        previewViewModel.addActivity(description: "Yoga", timestamp: tomorrow)
    }
    return AppCalendarView(viewModel: previewViewModel)
}
