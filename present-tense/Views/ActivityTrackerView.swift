import SwiftUI

struct ActivityTrackerView: View {
    @EnvironmentObject private var activityViewModel: ActivityViewModel
    @StateObject private var quickActionsViewModel = QuickActionsViewModel.shared
    @State private var showingAddActivity = false
    @State private var showingQuickActionsSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Selected Date Header
                    selectedDateHeader
                    
                    // Current Activity Card
                    currentActivityCard
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Today's Activities
                    todaysActivitiesSection
                }
                .padding()
            }
            .navigationTitle("Registro Diario")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingQuickActionsSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddActivity = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView()
                    .environmentObject(activityViewModel)
            }
            .sheet(isPresented: $showingQuickActionsSettings) {
                QuickActionsSettingsView()
                    .environmentObject(quickActionsViewModel)
            }
        }
    }
    
    private var selectedDateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Día seleccionado")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatSelectedDate())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedDateColor())
            }
            
            Spacer()
            
            // Date navigation buttons
            HStack(spacing: 12) {
                Button(action: previousDay) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Button(action: nextDay) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Button("Hoy") {
                    activityViewModel.selectedDate = Date()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var currentActivityCard: some View {
        Group {
            if let currentActivity = activityViewModel.currentActivity {
                CurrentActivityCard(activity: currentActivity) {
                    activityViewModel.stopCurrentActivity()
                }
            } else {
                EmptyCurrentActivityCard()
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Acciones Rápidas")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Personalizar") {
                    showingQuickActionsSettings = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(quickActionsViewModel.quickActions.prefix(6)), id: \.id) { quickAction in
                    QuickActionButtonCustom(quickAction: quickAction) {
                        startQuickActivity(quickAction: quickAction)
                    }
                }
            }
        }
    }
    
    private var todaysActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Actividades del día")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(activityViewModel.activitiesForSelectedDate.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            if activityViewModel.activitiesForSelectedDate.isEmpty {
                Text("No hay actividades registradas")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(activityViewModel.activitiesForSelectedDate) { activity in
                        ActivityRowView(activity: activity)
                            .environmentObject(activityViewModel)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(activityViewModel.selectedDate) {
            return "Hoy, \(formatter.string(from: activityViewModel.selectedDate))"
        } else if calendar.isDateInYesterday(activityViewModel.selectedDate) {
            return "Ayer, \(formatter.string(from: activityViewModel.selectedDate))"
        } else if calendar.isDateInTomorrow(activityViewModel.selectedDate) {
            return "Mañana, \(formatter.string(from: activityViewModel.selectedDate))"
        } else {
            formatter.dateStyle = .full
            return formatter.string(from: activityViewModel.selectedDate)
        }
    }
    
    private func selectedDateColor() -> Color {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(activityViewModel.selectedDate) {
            return .blue
        } else if activityViewModel.selectedDate < Date() {
            return .orange
        } else {
            return .green
        }
    }
    
    private func previousDay() {
        let calendar = Calendar.current
        if let previousDay = calendar.date(byAdding: .day, value: -1, to: activityViewModel.selectedDate) {
            activityViewModel.selectedDate = previousDay
        }
    }
    
    private func nextDay() {
        let calendar = Calendar.current
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: activityViewModel.selectedDate) {
            activityViewModel.selectedDate = nextDay
        }
    }
    
    private func startQuickActivity(quickAction: QuickAction) {
        activityViewModel.startActivity(title: quickAction.title, category: quickAction.category)
    }
}

struct CurrentActivityCard: View {
    let activity: Activity
    let onStop: () -> Void
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var elapsedTime: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Actividad Actual")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(activity.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Image(systemName: activity.category.iconName)
                    .font(.title2)
                    .foregroundColor(activity.category.color)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tiempo transcurrido")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatElapsedTime(elapsedTime))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(activity.category.color)
                }
                
                Spacer()
                
                Button("Detener") {
                    onStop()
                }
                .buttonStyle(.borderedProminent)
                .tint(activity.category.color)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(activity.category.color.opacity(0.1))
                .stroke(activity.category.color.opacity(0.3), lineWidth: 1)
        )
        .onReceive(timer) { _ in
            elapsedTime = Date().timeIntervalSince(activity.startTime)
        }
        .onAppear {
            elapsedTime = Date().timeIntervalSince(activity.startTime)
        }
    }
    
    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct EmptyCurrentActivityCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No hay actividad en curso")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Toca '+' para comenzar una nueva actividad")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct QuickActionButtonCustom: View {
    let quickAction: QuickAction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: quickAction.category.iconName)
                    .font(.title2)
                    .foregroundColor(quickAction.category.color)
                
                Text(quickAction.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(quickAction.category.color.opacity(0.1))
                    .stroke(quickAction.category.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ActivityRowView: View {
    let activity: Activity
    @EnvironmentObject private var activityViewModel: ActivityViewModel
    @State private var showingEdit = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: activity.category.iconName)
                .font(.title3)
                .foregroundColor(activity.category.color)
                .frame(width: 24, height: 24)
            
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let description = activity.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(formatTime(activity.startTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let endTime = activity.endTime {
                        Text("- \(formatTime(endTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("(\(activity.formattedDuration))")
                            .font(.caption)
                            .foregroundColor(activity.category.color)
                            .fontWeight(.medium)
                    } else {
                        Text("En curso")
                            .font(.caption)
                            .foregroundColor(activity.category.color)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .controlSize(.small)
                
                // Recurring indicator
                if activity.isRecurring {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
        )
        .contextMenu {
            Button("Editar") {
                showingEdit = true
            }
            
            Button("Eliminar", role: .destructive) {
                activityViewModel.deleteActivity(activity)
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditActivityView(activity: activity)
                .environmentObject(activityViewModel)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ActivityTrackerView()
        .environmentObject(ActivityViewModel.shared)
}