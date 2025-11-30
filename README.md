# UrunanTBku

A modern iOS expense tracking and settlement calculator app for groups, built with SwiftUI and Firebase.

## Overview

Mili helps groups track shared expenses and calculates who owes whom. The app supports two expense modes:
- **Urunan** - Split expenses equally among participants
- **Utang** - Track when a single person owes money

The app automatically calculates optimized settlements, minimizing the number of transfers needed to settle all debts.

## Features

### Expense Management
- Add, edit, duplicate, and delete expenses
- Two sharing modes: split equally (Urunan) or single debtor (Utang)
- Search expenses by title or notes
- Filter by sharing mode or participant
- Sort by date, price, or alphabetically
- Add optional notes to expenses

### People Management
- Add and manage group participants
- Customize each person with emoji avatars
- Assign custom colors (hex color support)
- Mark people as active/inactive
- Swipe actions for quick edits and deletions

### Settlement Summary
- Automatic debt calculation showing who owes whom
- Visualizes all person-to-person balances
- Generates optimized settlement transfers (minimum transactions)
- Detailed breakdown with visual cards and gradients
- Real-time balance updates

### Data Import/Export
- Export expense data to CSV format
- Import expenses from CSV files
- Automatic person creation during import
- CSV format: `title, price, buyer, participants, mode, date, notes`

### Cloud Sync
- Real-time data synchronization via Firebase/Firestore
- Automatic backup of all expenses and people
- Multi-device support

## Technology Stack

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Local data persistence
- **Firebase/Firestore** - Cloud database and real-time sync
- **Combine** - Reactive state management
- **MVVM Architecture** - Clean separation of concerns

## Project Structure

```
UrunanUtang/
├── App/
│   └── AppEnvironment.swift          # Dependency injection container
├── Models/
│   ├── Person.swift                   # Person data model
│   ├── ExpenseItem.swift              # Expense tracking model
│   ├── Settlement.swift               # Settlement calculation structures
│   └── Enums.swift                    # ShareMode enum
├── Views/
│   ├── Root/                          # Main navigation
│   ├── Items/                         # Expense list and forms
│   ├── Summary/                       # Settlement summary
│   ├── People/                        # People management
│   └── Settings/                      # Settings and CSV import
├── ViewModels/                        # View models for each feature
├── Services/
│   ├── FirestoreDataManager.swift     # Firestore CRUD operations
│   ├── SettlementCalculator.swift     # Debt calculation algorithm
│   ├── FilterSortService.swift        # Filtering and sorting logic
│   ├── CurrencyFormattingService.swift # Indonesian Rupiah formatting
│   └── ImportExportService.swift      # CSV import/export
├── Components/                        # Reusable UI components
├── Utils/                             # Extensions and utilities
└── Tests/                             # Unit tests
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase account with Firestore enabled

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd UrunanTBku
   ```

2. Install Firebase dependencies:
   - The project uses Firebase/Firestore for cloud sync
   - Add your `GoogleService-Info.plist` file to the project root
   - This file is gitignored for security and must be obtained from your Firebase console

3. Configure Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add an iOS app to your Firebase project
   - Download the `GoogleService-Info.plist` file
   - Place it in the project directory

4. Open the project:
   ```bash
   open UrunanTBku.xcodeproj
   ```

5. Build and run:
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

## Configuration

### Currency
The app is currently configured for Indonesian Rupiah (IDR) with locale `id_ID`. To change this, modify the currency service initialization in `AppEnvironment.swift:32`:

```swift
currency: CurrencyFormattingService(locale: Locale(identifier: "id_ID"))
```

### Firebase
Firebase initialization occurs on app launch. Real-time listeners start when the app appears. All configuration is handled automatically via `GoogleService-Info.plist`.

## Data Models

### Person
- Unique UUID identifier
- Name (required)
- Active status
- Optional emoji avatar
- Optional custom hex color

### ExpenseItem
- Unique UUID identifier
- Title and price (Decimal)
- Date and notes
- Buyer (Person relationship)
- Participants (Person array)
- ShareMode (urunan or utang)

### Settlement
- `PersonTotal`: Tracks paid, owed, and net balance per person
- `PairwiseDebt`: Represents a transfer from one person to another
- `SettlementSummary`: Contains totals, transfers, and debt matrix

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture:

- **Models**: SwiftData models for persistence
- **Views**: SwiftUI views for UI
- **ViewModels**: Business logic and state management
- **Services**: Reusable business logic (injected via `AppEnvironment`)

All services are injected through the `AppEnvironment` class, following dependency injection patterns for better testability.
