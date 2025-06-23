import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("colorSchemePreference") var colorSchemeOption: ColorSchemeOption = .system
    @AppStorage("defaultActivityDuration") var defaultActivityDuration: Double = 60 // minutes
    @AppStorage("enableNotifications") var enableNotifications: Bool = true
    @AppStorage("enableAutoStop") var enableAutoStop: Bool = false
    @AppStorage("autoStopDuration") var autoStopDuration: Double = 120 // minutes
    @AppStorage("enableHapticFeedback") var enableHapticFeedback: Bool = true
    @AppStorage("enableSounds") var enableSounds: Bool = true
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    @AppStorage("enableCloudSync") var enableCloudSync: Bool = false
    @AppStorage("lastSyncDate") var lastSyncDate: Date = Date()
    
    @Published var isExportingData: Bool = false
    @Published var isImportingData: Bool = false
    @Published var showingExportSheet: Bool = false
    @Published var showingImportSheet: Bool = false
    @Published var showingResetAlert: Bool = false
    
    private let activityViewModel: ActivityViewModel
    
    init(activityViewModel: ActivityViewModel = .shared) {
        self.activityViewModel = activityViewModel
    }
    
    // MARK: - Theme Management
    var currentColorScheme: ColorScheme? {
        colorSchemeOption.toSwiftUIScheme()
    }
    
    func updateColorScheme(_ option: ColorSchemeOption) {
        colorSchemeOption = option
    }
    
    // MARK: - Data Management
    func exportData() async {
        isExportingData = true
        defer { isExportingData = false }
        
        do {
            let data = try JSONEncoder().encode(activityViewModel.activities)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "present_tense_backup_\(Date().timeIntervalSince1970).json"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            
            DispatchQueue.main.async {
                self.showingExportSheet = true
            }
        } catch {
            print("Error exporting data: \(error)")
        }
    }
    
    func importData(from url: URL) async {
        isImportingData = true
        defer { isImportingData = false }
        
        do {
            let data = try Data(contentsOf: url)
            let importedActivities = try JSONDecoder().decode([Activity].self, from: data)
            
            DispatchQueue.main.async {
                self.activityViewModel.activities = importedActivities
            }
        } catch {
            print("Error importing data: \(error)")
        }
    }
    
    func resetAllData() {
        activityViewModel.activities.removeAll()
        
        // Reset settings to defaults
        colorSchemeOption = .system
        defaultActivityDuration = 60
        enableNotifications = true
        enableAutoStop = false
        autoStopDuration = 120
        enableHapticFeedback = true
        enableSounds = true
        enableCloudSync = false
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "SavedActivities")
    }
    
    // MARK: - Notification Settings
    func requestNotificationPermission() {
        // TODO: Implement notification permission request
    }
    
    // MARK: - Cloud Sync
    func syncWithCloud() async {
        guard enableCloudSync else { return }
        
        // TODO: Implement CloudKit sync
        lastSyncDate = Date()
    }
    
    // MARK: - App Info
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var totalActivities: Int {
        activityViewModel.activities.count
    }
    
    var totalTimeLogged: TimeInterval {
        activityViewModel.activities.compactMap { activity in
            activity.endTime != nil ? activity.duration : nil
        }.reduce(0, +)
    }
    
    var formattedTotalTime: String {
        let hours = Int(totalTimeLogged) / 3600
        let minutes = Int(totalTimeLogged) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    var daysOfUsage: Int {
        let uniqueDays = Set(activityViewModel.activities.map { $0.dayIdentifier })
        return uniqueDays.count
    }
    
    // MARK: - Default Categories
    var favoriteCategories: [ActivityCategory] {
        let categoryCount = Dictionary(grouping: activityViewModel.activities) { $0.category }
            .mapValues { $0.count }
        
        return categoryCount.sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
    
    // MARK: - Formatting Helpers
    func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 60
        let minutes = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(Int(duration))m"
        }
    }
}