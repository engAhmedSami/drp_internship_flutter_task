# Trip Manager Flutter App

A Flutter application for managing trips, drivers, and vehicles with a modern UI and comprehensive functionality.

## Setup Instructions

### Prerequisites
- Flutter SDK (version 3.9.2 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Android/iOS device or emulator for testing

### Installation
1. Clone this repository
2. Navigate to the project directory:
   ```bash
   cd drp_internship_flutter_task
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Assumptions Made

- **Data Storage**: The app uses in-memory data storage with mock data service for demonstration purposes
- **State Management**: Provider pattern is used for state management across the application
- **API Integration**: Mock data is used instead of real API endpoints
- **Authentication**: No authentication system is implemented as it wasn't specified in requirements
- **Offline Support**: Basic offline functionality through local state management
- **Platform Support**: Designed primarily for mobile (Android/iOS) with responsive design principles

## Features Implemented

### Core Functionality
- **Trip Management**: Create, view, edit, and manage trips
- **Driver Management**: Assign and manage drivers for trips
- **Vehicle Management**: Assign and manage vehicles for trips
- **Status Tracking**: Track trip status (Pending, In Progress, Completed, Cancelled)

### UI/UX Features
- **Modern Material Design**: Clean and intuitive user interface
- **Tab Navigation**: Easy navigation between different trip status categories
- **Search Functionality**: Search trips by various criteria
- **Status Badges**: Visual status indicators for quick identification
- **Responsive Cards**: Trip information displayed in organized card format
- **Custom Theme**: Consistent color scheme and typography throughout the app

### Technical Features
- **Provider State Management**: Efficient state management using Provider package
- **Data Validation**: Input validation for trip creation and editing
- **UUID Generation**: Unique identifiers for all entities
- **Date Formatting**: Proper date handling and formatting using intl package
- **Custom Widgets**: Reusable components for consistent UI

## Screen Choice: Trips

I chose to implement the **Trips** screen as the main focus of this application because:

1. **Central Entity**: Trips serve as the central business entity that connects drivers and vehicles, making it the most logical starting point for a transportation management system.

2. **Comprehensive Workflow**: The trips screen demonstrates the complete workflow from trip creation to completion, showcasing the full lifecycle management.

3. **Complex State Management**: Trips have multiple status states (Pending, In Progress, Completed, Cancelled) which allows demonstration of advanced state management patterns.

4. **Rich Data Display**: Trip cards can display comprehensive information including route details, assigned driver/vehicle, timing, and status - providing excellent opportunity to showcase UI/UX design skills.

5. **Business Value**: In a real-world transportation management system, trip management is typically the most critical functionality that directly impacts business operations and customer satisfaction.

The trips screen includes filtering by status, search functionality, trip assignment capabilities, and detailed trip views, making it a comprehensive demonstration of Flutter development capabilities.

## Project Structure

```
lib/
├── models/          # Data models (Trip, Driver, Vehicle)
├── providers/       # State management providers
├── screens/         # UI screens
├── widgets/         # Reusable UI components
├── services/        # Data services and API handlers
├── utils/           # Utilities, constants, and helpers
└── theme/           # App theming and styling
```

## Dependencies

- **provider**: State management
- **uuid**: Unique identifier generation
- **intl**: Date and number formatting
- **cupertino_icons**: iOS-style icons
- **flutter_lints**: Code quality and linting
