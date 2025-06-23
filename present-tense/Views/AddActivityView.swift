import SwiftUI

struct AddActivityView: View {
    @EnvironmentObject private var activityViewModel: ActivityViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: ActivityCategory = .work
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var hasEndTime = false
    @State private var isRecurring = false
    @State private var recurringPattern: RecurringPattern = .daily
    @State private var tags: [String] = []
    @State private var newTag = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Básica") {
                    TextField("Título de la actividad", text: $title)
                    
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(ActivityCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.color)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Tiempo") {
                    DatePicker("Hora de inicio", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Tiene hora de finalización", isOn: $hasEndTime)
                    
                    if hasEndTime {
                        DatePicker("Hora de finalización", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Actividad Recurrente") {
                    Toggle("Es una actividad recurrente", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Patrón de recurrencia", selection: $recurringPattern) {
                            ForEach(RecurringPattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Etiquetas") {
                    HStack {
                        TextField("Agregar etiqueta", text: $newTag)
                        
                        Button("Agregar") {
                            addTag()
                        }
                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagView(tag: tag) {
                                    removeTag(tag)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nueva Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveActivity()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            endTime = startTime.addingTimeInterval(3600) // Default 1 hour duration
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveActivity() {
        let finalEndTime = hasEndTime ? endTime : nil
        
        let activity = Activity(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            startTime: startTime,
            endTime: finalEndTime,
            category: selectedCategory,
            isRecurring: isRecurring,
            recurringPattern: isRecurring ? recurringPattern : nil,
            tags: tags
        )
        
        activityViewModel.addActivity(activity)
        dismiss()
    }
}

struct EditActivityView: View {
    @EnvironmentObject private var activityViewModel: ActivityViewModel
    @Environment(\.dismiss) private var dismiss
    
    let activity: Activity
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: ActivityCategory
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var hasEndTime: Bool
    @State private var isRecurring: Bool
    @State private var recurringPattern: RecurringPattern
    @State private var tags: [String]
    @State private var newTag = ""
    
    init(activity: Activity) {
        self.activity = activity
        _title = State(initialValue: activity.title)
        _description = State(initialValue: activity.description ?? "")
        _selectedCategory = State(initialValue: activity.category)
        _startTime = State(initialValue: activity.startTime)
        _endTime = State(initialValue: activity.endTime ?? Date())
        _hasEndTime = State(initialValue: activity.endTime != nil)
        _isRecurring = State(initialValue: activity.isRecurring)
        _recurringPattern = State(initialValue: activity.recurringPattern ?? .daily)
        _tags = State(initialValue: activity.tags)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Básica") {
                    TextField("Título de la actividad", text: $title)
                    
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(ActivityCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.color)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Tiempo") {
                    DatePicker("Hora de inicio", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Tiene hora de finalización", isOn: $hasEndTime)
                    
                    if hasEndTime {
                        DatePicker("Hora de finalización", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Actividad Recurrente") {
                    Toggle("Es una actividad recurrente", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Patrón de recurrencia", selection: $recurringPattern) {
                            ForEach(RecurringPattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Etiquetas") {
                    HStack {
                        TextField("Agregar etiqueta", text: $newTag)
                        
                        Button("Agregar") {
                            addTag()
                        }
                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagView(tag: tag) {
                                    removeTag(tag)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Editar Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveActivity()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveActivity() {
        let finalEndTime = hasEndTime ? endTime : nil
        
        var updatedActivity = activity
        updatedActivity.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedActivity.description = description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedActivity.category = selectedCategory
        updatedActivity.startTime = startTime
        updatedActivity.endTime = finalEndTime
        updatedActivity.isRecurring = isRecurring
        updatedActivity.recurringPattern = isRecurring ? recurringPattern : nil
        updatedActivity.tags = tags
        
        activityViewModel.updateActivity(updatedActivity)
        dismiss()
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}

#Preview {
    AddActivityView()
        .environmentObject(ActivityViewModel.shared)
}