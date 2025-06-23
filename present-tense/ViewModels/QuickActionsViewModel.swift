import Foundation
import Combine

class QuickActionsViewModel: ObservableObject {
    @Published var quickActions: [QuickAction] = []
    
    static let shared = QuickActionsViewModel()
    
    init() {
        loadQuickActions()
    }
    
    // MARK: - Quick Actions Management
    func addQuickAction(title: String, category: ActivityCategory) {
        let newAction = QuickAction(title: title, category: category, isDefault: false)
        quickActions.append(newAction)
        saveQuickActions()
    }
    
    func updateQuickAction(_ action: QuickAction) {
        if let index = quickActions.firstIndex(where: { $0.id == action.id }) {
            quickActions[index] = action
            saveQuickActions()
        }
    }
    
    func deleteQuickAction(_ action: QuickAction) {
        // Don't allow deletion of default actions
        guard !action.isDefault else { return }
        quickActions.removeAll { $0.id == action.id }
        saveQuickActions()
    }
    
    func moveQuickAction(from source: IndexSet, to destination: Int) {
        quickActions.move(fromOffsets: source, toOffset: destination)
        saveQuickActions()
    }
    
    // MARK: - Persistence
    private func saveQuickActions() {
        do {
            let data = try JSONEncoder().encode(quickActions)
            UserDefaults.standard.set(data, forKey: "SavedQuickActions")
        } catch {
            print("Error saving quick actions: \(error)")
        }
    }
    
    private func loadQuickActions() {
        if let data = UserDefaults.standard.data(forKey: "SavedQuickActions") {
            do {
                quickActions = try JSONDecoder().decode([QuickAction].self, from: data)
            } catch {
                print("Error loading quick actions: \(error)")
                loadDefaultActions()
            }
        } else {
            loadDefaultActions()
        }
    }
    
    private func loadDefaultActions() {
        quickActions = QuickAction.defaultActions
        saveQuickActions()
    }
    
    // MARK: - Helpers
    var customActions: [QuickAction] {
        quickActions.filter { !$0.isDefault }
    }
    
    var defaultActions: [QuickAction] {
        quickActions.filter { $0.isDefault }
    }
    
    func canDelete(_ action: QuickAction) -> Bool {
        !action.isDefault
    }
}