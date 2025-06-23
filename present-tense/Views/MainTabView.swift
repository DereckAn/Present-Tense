import SwiftUI

struct MainTabView: View {
    @StateObject private var activityViewModel = ActivityViewModel.shared
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            ActivityTrackerView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Registrar")
                }
                .environmentObject(activityViewModel)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendario")
                }
                .environmentObject(activityViewModel)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Estadísticas")
                }
                .environmentObject(statisticsViewModel)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Ajustes")
                }
                .environmentObject(settingsViewModel)
        }
        .accentColor(.primary)
    }
}