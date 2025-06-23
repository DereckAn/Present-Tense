import SwiftUI

struct QuickActionsSettingsView: View {
    @EnvironmentObject private var quickActionsViewModel: QuickActionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddAction = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Acciones Predeterminadas") {
                    ForEach(quickActionsViewModel.defaultActions) { action in
                        QuickActionRow(action: action, canEdit: false, canDelete: false)
                    }
                }
                
                Section("Acciones Personalizadas") {
                    ForEach(quickActionsViewModel.customActions) { action in
                        QuickActionRow(
                            action: action,
                            canEdit: true,
                            canDelete: true,
                            onEdit: { editedAction in
                                quickActionsViewModel.updateQuickAction(editedAction)
                            },
                            onDelete: {
                                quickActionsViewModel.deleteQuickAction(action)
                            }
                        )
                    }
                    .onMove(perform: quickActionsViewModel.moveQuickAction)
                }
            }
            .navigationTitle("Acciones Rápidas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddAction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAction) {
                AddQuickActionView()
                    .environmentObject(quickActionsViewModel)
            }
        }
    }
}

struct QuickActionRow: View {
    let action: QuickAction
    let canEdit: Bool
    let canDelete: Bool
    var onEdit: ((QuickAction) -> Void)?
    var onDelete: (() -> Void)?
    
    @EnvironmentObject private var quickActionsViewModel: QuickActionsViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: action.category.iconName)
                .font(.title3)
                .foregroundColor(action.category.color)
                .frame(width: 30, height: 30)
                .background(action.category.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(action.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(action.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if action.isDefault {
                Text("Predeterminada")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.secondary)
                    .clipShape(Capsule())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if canEdit {
                showingEditSheet = true
            }
        }
        .contextMenu {
            if canEdit {
                Button("Editar") {
                    showingEditSheet = true
                }
            }
            
            if canDelete {
                Button("Eliminar", role: .destructive) {
                    onDelete?()
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditQuickActionView(action: action) { editedAction in
                onEdit?(editedAction)
            }
            .environmentObject(quickActionsViewModel)
        }
    }
}

struct AddQuickActionView: View {
    @EnvironmentObject private var quickActionsViewModel: QuickActionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var selectedCategory: ActivityCategory = .work
    
    var body: some View {
        NavigationView {
            Form {
                Section("Nueva Acción Rápida") {
                    TextField("Nombre de la acción", text: $title)
                    
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
                
                Section {
                    HStack {
                        Image(systemName: selectedCategory.iconName)
                            .font(.title2)
                            .foregroundColor(selectedCategory.color)
                            .frame(width: 40, height: 40)
                            .background(selectedCategory.color.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(title.isEmpty ? "Nombre de la acción" : title)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(title.isEmpty ? .secondary : .primary)
                            
                            Text(selectedCategory.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Vista Previa")
                }
            }
            .navigationTitle("Nueva Acción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveAction()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveAction() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        quickActionsViewModel.addQuickAction(title: trimmedTitle, category: selectedCategory)
        dismiss()
    }
}

struct EditQuickActionView: View {
    let action: QuickAction
    let onSave: (QuickAction) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var selectedCategory: ActivityCategory
    
    init(action: QuickAction, onSave: @escaping (QuickAction) -> Void) {
        self.action = action
        self.onSave = onSave
        _title = State(initialValue: action.title)
        _selectedCategory = State(initialValue: action.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Editar Acción Rápida") {
                    TextField("Nombre de la acción", text: $title)
                    
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
                
                Section {
                    HStack {
                        Image(systemName: selectedCategory.iconName)
                            .font(.title2)
                            .foregroundColor(selectedCategory.color)
                            .frame(width: 40, height: 40)
                            .background(selectedCategory.color.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(title.isEmpty ? "Nombre de la acción" : title)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(title.isEmpty ? .secondary : .primary)
                            
                            Text(selectedCategory.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Vista Previa")
                }
            }
            .navigationTitle("Editar Acción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveAction()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveAction() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var updatedAction = action
        updatedAction.title = trimmedTitle
        updatedAction.category = selectedCategory
        onSave(updatedAction)
        dismiss()
    }
}

#Preview {
    QuickActionsSettingsView()
        .environmentObject(QuickActionsViewModel.shared)
}
