# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Present-Tense is a comprehensive SwiftUI-based iOS activity tracking application that allows users to log daily activities, view them in calendar format, analyze statistics, and manage settings. The app follows MVVM architecture with clear separation of concerns and includes features like recurring activities, categories, and cloud sync preparation.

## Development Commands

### Building and Running
- Open project: `open present-tense.xcodeproj`
- Build and run: Use Xcode's Run button or ⌘+R
- No external dependencies - pure SwiftUI project

### Testing
- Run UI tests: Use Xcode's Test Navigator or ⌘+U
- UI test files located in `present-tenseUITests/`

## Architecture

### MVVM Pattern
- **Models** (`Models/`): Core data structures
  - `Activity.swift`: Main activity model with timestamps, categories, and recurring patterns
  - `ActivityCategory.swift`: Enum defining activity categories with colors and icons
- **Views** (`Views/`): SwiftUI view components organized by feature
- **ViewModels** (`ViewModels/`): Business logic and state management
- **Schemas** (`Schemas/`): Data schemas like `ColorSchemeOption`

### Key Components

#### Activity Model (`Models/Activity.swift`)
- Core data structure: `id`, `title`, `description`, `startTime`, `endTime`, `category`, `isRecurring`, `recurringPattern`, `tags`
- Conforms to `Identifiable`, `Codable`, `Hashable`
- Uses UUID for unique identification
- Includes computed properties for duration formatting and day identification
- Supports recurring patterns: daily, weekly, monthly, weekdays, weekends

#### ActivityCategory Model (`Models/ActivityCategory.swift`)
- Enum with predefined categories: work, sleep, food, exercise, social, hobby, etc.
- Each category has: display name, SF Symbol icon, and associated color
- Provides consistency across the app for activity categorization

#### ViewModels

**ActivityViewModel** (`ViewModels/ActivityViewModel.swift`)
- Singleton shared instance for app-wide state management
- Uses `@Published var activities: [Activity]` for reactive updates
- Handles CRUD operations: `addActivity()`, `updateActivity()`, `deleteActivity()`
- Manages current activity tracking with start/stop functionality
- Provides date filtering and statistical calculations
- Handles persistence via UserDefaults (JSON encoding)

**StatisticsViewModel** (`ViewModels/StatisticsViewModel.swift`)
- Analyzes activity data for insights and trends
- Supports multiple time ranges: day, week, month, year
- Generates category statistics with percentages and totals
- Provides daily and weekly activity patterns
- Calculates summary stats like total time, activity count, averages

**SettingsViewModel** (`ViewModels/SettingsViewModel.swift`)
- Manages app preferences via `@AppStorage`
- Handles theme/color scheme selection
- Provides data export/import functionality
- Manages notification and auto-stop settings
- Tracks app usage statistics and favorite categories

### Navigation Structure
- **ContentView**: Root view managing color scheme preferences
- **MainTabView**: Tab-based navigation with 4 main sections:
  1. **ActivityTrackerView**: Register and track activities
  2. **CalendarView**: View activities by date with calendar interface
  3. **StatisticsView**: Analyze activity patterns and statistics
  4. **SettingsView**: App configuration and data management

### State Management
- Uses `@AppStorage` for persistent user preferences
- `@Published` properties in ViewModels for reactive UI updates
- Environment objects for dependency injection
- UserDefaults for activity data persistence (JSON format)

### Key Features

#### Activity Tracking
- Start/stop activity tracking with live timer
- Customizable quick action buttons (users can add/edit/delete their own)
- Full activity creation with categories, descriptions, and tags
- Support for recurring activity patterns
- Edit and delete existing activities
- Date navigation with color coding (blue=today, orange=past, green=future)
- Scrollable activity list with edit buttons
- Live activity tracking with real-time timer updates

#### Calendar Integration
- Month view with activity indicators
- Day selection with activity list
- Visual indicators for days with activities
- Month/year navigation and selection

#### Statistics & Analytics
- Multiple time range analysis (day/week/month/year)
- Category distribution charts (requires iOS 16+ for Charts framework)
- Daily and weekly activity patterns
- Summary statistics and insights
- Progress tracking for different categories

#### Settings & Data Management
- Theme selection (light/dark/system)
- Activity duration defaults and auto-stop settings
- Data export/import via JSON files
- App usage statistics
- Cloud sync preparation (CloudKit integration ready)

## Data Flow
1. User interactions trigger ViewModel methods
2. ViewModels update `@Published` properties
3. SwiftUI automatically updates bound views
4. Data persistence handled through UserDefaults
5. Environment objects provide dependency injection across views

## Key Files to Understand

### Core Structure
- `present_tenseApp.swift`: App entry point
- `ContentView.swift`: Root view with theme management
- `MainTabView.swift`: Main navigation structure

### Models
- `Activity.swift`: Primary data model with full activity information
- `ActivityCategory.swift`: Category definitions with UI elements
- `QuickAction.swift`: Customizable quick action buttons model

### ViewModels
- `ActivityViewModel.swift`: Core business logic and state management
- `StatisticsViewModel.swift`: Analytics and data analysis
- `SettingsViewModel.swift`: App configuration and preferences
- `QuickActionsViewModel.swift`: Management of customizable quick actions

### Views
- `ActivityTrackerView.swift`: Main activity tracking interface with scrollable content
- `CalendarView.swift`: Calendar-based activity viewing
- `StatisticsView.swift`: Analytics dashboard with charts
- `SettingsView.swift`: Configuration and data management
- `AddActivityView.swift`: Activity creation and editing forms
- `QuickActionsSettingsView.swift`: Management interface for custom quick actions

## Development Notes

- Project uses SF Symbols for consistent iconography
- Color scheme supports light/dark/system modes with @AppStorage persistence
- Date handling uses Calendar components for reliable day-based filtering
- No external dependencies - pure SwiftUI implementation
- Statistics use iOS 16+ Charts framework with fallbacks for older versions
- CloudKit integration prepared but not yet implemented
- Data persistence currently via UserDefaults with JSON encoding
- Spanish language UI with English code comments