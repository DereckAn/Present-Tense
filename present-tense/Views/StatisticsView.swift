import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel
    @State private var selectedTab: StatTab = .overview
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Time Range Picker
                timeRangePicker
                
                // Tab Picker
                tabPicker
                
                // Content
                TabView(selection: $selectedTab) {
                    OverviewStatsView()
                        .environmentObject(statisticsViewModel)
                        .tag(StatTab.overview)
                    
                    CategoryStatsView()
                        .environmentObject(statisticsViewModel)
                        .tag(StatTab.categories)
                    
                    TrendsStatsView()
                        .environmentObject(statisticsViewModel)
                        .tag(StatTab.trends)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Estadísticas")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeRangePicker: some View {
        Picker("Rango de tiempo", selection: $statisticsViewModel.selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var tabPicker: some View {
        Picker("Pestaña", selection: $selectedTab) {
            ForEach(StatTab.allCases, id: \.self) { tab in
                Text(tab.displayName).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

enum StatTab: String, CaseIterable {
    case overview = "overview"
    case categories = "categories"
    case trends = "trends"
    
    var displayName: String {
        switch self {
        case .overview: return "Resumen"
        case .categories: return "Categorías"
        case .trends: return "Tendencias"
        }
    }
}

struct OverviewStatsView: View {
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Summary Cards
                summaryCards
                
                // Top Categories
                topCategoriesSection
                
                // Recent Activity Pattern
                recentActivitySection
            }
            .padding()
        }
    }
    
    private var summaryCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            StatCard(
                title: "Tiempo Total",
                value: formatTimeInterval(statisticsViewModel.totalTimeInRange),
                icon: "clock.fill",
                color: .blue
            )
            
            StatCard(
                title: "Actividades",
                value: "\(statisticsViewModel.totalActivitiesInRange)",
                icon: "list.bullet",
                color: .green
            )
            
            StatCard(
                title: "Promedio por Actividad",
                value: formatTimeInterval(statisticsViewModel.averageActivityDuration),
                icon: "timer",
                color: .orange
            )
            
            StatCard(
                title: "Día Más Activo",
                value: statisticsViewModel.mostActiveDay ?? "-",
                icon: "star.fill",
                color: .purple
            )
        }
    }
    
    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categorías Principales")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Array(statisticsViewModel.categoryStatsWithPercentages.prefix(5)), id: \.category) { stat in
                    CategoryProgressRow(stat: stat)
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patrón de Actividad Diario")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart(statisticsViewModel.dailyPattern, id: \.hour) { hourStat in
                    BarMark(
                        x: .value("Hora", hourStat.hour),
                        y: .value("Tiempo", hourStat.totalTime / 60)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: Array(stride(from: 0, through: 23, by: 4))) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let hour = value.as(Int.self) {
                                Text("\(hour):00")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let minutes = value.as(Double.self) {
                                Text("\(Int(minutes))m")
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS < 16
                Text("Gráfico de actividad diaria requiere iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CategoryStatsView: View {
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Category Distribution Chart
                categoryDistributionChart
                
                // Detailed Category Stats
                categoryDetailsList
            }
            .padding()
        }
    }
    
    private var categoryDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución por Categorías")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart(statisticsViewModel.categoryStatsWithPercentages, id: \.category) { stat in
                    SectorMark(
                        angle: .value("Tiempo", stat.totalTime),
                        innerRadius: .ratio(0.4),
                        outerRadius: .ratio(0.8)
                    )
                    .foregroundStyle(stat.category.color)
                    .opacity(0.8)
                }
                .frame(height: 250)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        if let plotFrame = chartProxy.plotFrame {
                            let center = CGPoint(
                                x: geometry[plotFrame].midX,
                                y: geometry[plotFrame].midY
                            )
                            VStack {
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatTimeInterval(statisticsViewModel.totalTimeInRange))
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .position(center)
                        }
                    }
                }
            } else {
                // Fallback for iOS < 16
                Text("Gráfico de distribución requiere iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var categoryDetailsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detalles por Categoría")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(statisticsViewModel.categoryStatsWithPercentages, id: \.category) { stat in
                    CategoryDetailRow(stat: stat)
                }
            }
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TrendsStatsView: View {
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Weekly Pattern
                weeklyPatternSection
                
                // Daily Pattern
                dailyPatternSection
            }
            .padding()
        }
    }
    
    private var weeklyPatternSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patrón Semanal")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart(statisticsViewModel.weeklyPattern, id: \.weekday) { weekdayStat in
                    BarMark(
                        x: .value("Día", weekdayStat.weekdayName),
                        y: .value("Tiempo", weekdayStat.totalTime / 3600)
                    )
                    .foregroundStyle(.green.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(Int(hours))h")
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS < 16
                VStack(spacing: 8) {
                    ForEach(statisticsViewModel.weeklyPattern, id: \.weekday) { weekdayStat in
                        HStack {
                            Text(weekdayStat.weekdayName)
                                .font(.caption)
                                .frame(width: 50, alignment: .leading)
                            
                            ProgressView(value: weekdayStat.totalTime, total: statisticsViewModel.weeklyPattern.map(\.totalTime).max() ?? 1)
                                .tint(.green)
                            
                            Text(weekdayStat.formattedTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var dailyPatternSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actividad por Hora del Día")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 4) {
                ForEach(statisticsViewModel.dailyPattern.filter { $0.totalTime > 0 }, id: \.hour) { hourStat in
                    HStack {
                        Text(hourStat.formattedHour)
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(width: 50, alignment: .leading)
                        
                        ProgressView(value: hourStat.totalTime, total: statisticsViewModel.dailyPattern.map(\.totalTime).max() ?? 1)
                            .tint(.blue)
                        
                        Text(hourStat.formattedTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct CategoryProgressRow: View {
    let stat: CategoryStat
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: stat.category.iconName)
                .font(.body)
                .foregroundColor(stat.category.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(stat.category.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(stat.formattedPercentage)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(stat.category.color)
                }
                
                ProgressView(value: stat.percentage, total: 100)
                    .tint(stat.category.color)
                
                Text(stat.formattedTotalTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CategoryDetailRow: View {
    let stat: CategoryStat
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: stat.category.iconName)
                .font(.title3)
                .foregroundColor(stat.category.color)
                .frame(width: 30, height: 30)
                .background(stat.category.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.category.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(stat.count) actividades")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Promedio: \(stat.formattedAverageTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(stat.formattedTotalTime)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(stat.category.color)
                
                Text(stat.formattedPercentage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(StatisticsViewModel())
}
