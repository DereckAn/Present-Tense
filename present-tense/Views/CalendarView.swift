import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var activityViewModel: ActivityViewModel
    @State private var selectedDate = Date()
    @State private var showingMonthYear = false
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar Header
                calendarHeader
                
                // Calendar Grid
                calendarGrid
                
                // Selected Date Activities
                selectedDateActivities
            }
            .navigationTitle("Calendario")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            activityViewModel.selectedDate = selectedDate
        }
    }
    
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: { showingMonthYear = true }) {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .sheet(isPresented: $showingMonthYear) {
                MonthYearPickerView(selectedDate: $selectedDate)
            }
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDate(date, inSameDayAs: Date()),
                        isCurrentMonth: calendar.isDate(date, equalTo: selectedDate, toGranularity: .month),
                        hasActivities: hasActivities(for: date),
                        activityCount: activityCount(for: date)
                    ) {
                        selectedDate = date
                        activityViewModel.selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var selectedDateActivities: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Actividades del \(selectedDateString)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !activitiesForSelectedDate.isEmpty {
                    Text("\(activitiesForSelectedDate.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
            
            if activitiesForSelectedDate.isEmpty {
                Text("No hay actividades registradas")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(activitiesForSelectedDate) { activity in
                            CalendarActivityRowView(activity: activity)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Calendar Logic
    private var monthYearString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    private var selectedDateString: String {
        dateFormatter.dateFormat = "d 'de' MMMM"
        return dateFormatter.string(from: selectedDate)
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate
        
        let startOfCalendar = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        let endOfCalendar = calendar.dateInterval(of: .weekOfYear, for: endOfMonth)?.end ?? endOfMonth
        
        var days: [Date] = []
        var currentDate = startOfCalendar
        
        while currentDate < endOfCalendar {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private var activitiesForSelectedDate: [Activity] {
        activityViewModel.activitiesForDate(selectedDate)
    }
    
    private func hasActivities(for date: Date) -> Bool {
        !activityViewModel.activitiesForDate(date).isEmpty
    }
    
    private func activityCount(for date: Date) -> Int {
        activityViewModel.activitiesForDate(date).count
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasActivities: Bool
    let activityCount: Int
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(textColor)
                
                if hasActivities {
                    Circle()
                        .fill(indicatorColor)
                        .frame(width: 6, height: 6)
                } else {
                    Spacer()
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        isSelected ? .blue : .clear
    }
    
    private var indicatorColor: Color {
        if isSelected {
            return .white
        } else {
            return .blue
        }
    }
}

struct CalendarActivityRowView: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(spacing: 2) {
                Text(formatTime(activity.startTime))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let endTime = activity.endTime {
                    Text(formatTime(endTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("En curso")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 50)
            
            // Activity info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: activity.category.iconName)
                        .font(.caption)
                        .foregroundColor(activity.category.color)
                    
                    Text(activity.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if activity.endTime != nil {
                        Text(activity.formattedDuration)
                            .font(.caption)
                            .foregroundColor(activity.category.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(activity.category.color.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                if let description = activity.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .stroke(activity.category.color.opacity(0.2), lineWidth: 0.5)
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MonthYearPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Seleccionar mes y año",
                    selection: $tempDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Seleccionar Fecha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Seleccionar") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(ActivityViewModel.shared)
}