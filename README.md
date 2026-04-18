# Budget Tracker

A modern, intelligent Flutter application that helps you track expenses, manage your budget, and gain AI-powered financial insights — all stored locally on your device.

![Flutter](https://img.shields.io/badge/Flutter-3.11.5-blue?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

##  Features

###  Smart Transaction Management
- **Add Income & Expenses** — Quickly log transactions with titles, amounts, categories, and dates
- **Auto-Categorization** — AI-powered keyword matching automatically categorizes your expenses (Food, Travel, Bills, Shopping, Entertainment, Health, Education)
- **Transaction History** — Browse and search all your past transactions in a clean, organized list

### Insights
- **Spending Analysis** — Discover your highest spending categories
- **Activity Trends** — Track whether your transaction activity is rising, falling, or steady
- **Financial Health Score** — Get a 0-100 score based on your income vs. expenses ratio
- **Smart Warnings** — Receive alerts when your expenses exceed your income

### Beautiful UI/UX
- **Material Design 3** — Modern, polished interface with smooth animations
- **Interactive Charts** — Visualize spending breakdowns with beautiful pie charts powered by fl_chart
- **Summary Cards** — Quick overview of income, expenses, and budget status
- **Dark & Light Themes** — Eye-friendly color scheme with fintech-style design

### Local-First Architecture
- **SQLite Database** — Fast, reliable local storage for all your financial data
- **Privacy-First** — No cloud servers, no data leaks — everything stays on your device
- **Offline Support** — Full functionality without internet connection

## Getting Started

### Prerequisites

- Flutter SDK **3.11.5** or higher
- Dart SDK **3.11.5** or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shayanahmad756/AI-Budget-Tracker.git
   cd AI-Budget-Tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For Web
   flutter run -d chrome --web-hostname=localhost
   
   # For Windows
   flutter run -d windows
   ```

## Architecture

This project follows a clean, scalable architecture:

```
lib/
├── models/
│   └── transaction_model.dart      # Data models
├── providers/
│   └── transaction_provider.dart   # State management (Provider)
├── screens/
│   ├── home_screen.dart            # Main dashboard
│   ├── add_transaction_screen.dart # Add new transactions
│   └── history_screen.dart         # Transaction history
├── services/
│   ├── ai_service.dart             # AI insights & categorization
│   └── database_service.dart       # SQLite operations
├── utils/
│   └── constants.dart              # Colors, categories, constants
├── widgets/
│   ├── insight_card.dart           # AI insights display
│   ├── summary_card.dart           # Financial summary cards
│   └── transaction_tile.dart       # Transaction list items
└── main.dart                       # App entry point
```

### Design Patterns Used
- **Provider Pattern** — Efficient state management for transactions
- **Service Layer** — Separation of concerns for database and AI logic
- **Repository Pattern** — Clean data access abstraction

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Provider** | State management |
| **SQLite (sqflite)** | Local database storage |
| **fl_chart** | Beautiful charts and graphs |
| **intl** | Date formatting and localization |
| **path_provider** | File system paths |

## Features Explained

### Smart Categorization
The app uses keyword matching to automatically categorize expenses:

```dart
// Examples:
"biryani lunch"      → Food
"uber ride"          → Travel
"electricity bill"   → Bills
"netflix subscription" → Entertainment
```

### Financial Health Score
Calculate your financial health on a scale of 0-100:
- **100** = All income saved (perfect)
- **50** = Half income saved (good)
- **0** = Expenses far exceed income (warning)

### Spending Insights
- Identifies your top spending category
- Compares recent vs. previous week activity
- Alerts when expenses > income

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # State management
  sqflite: ^2.4.2           # SQLite database
  idb_shim: ^2.3.2          # IndexedDB for web
  path: ^1.9.0              # Path manipulation
  path_provider: ^2.1.5     # Platform paths
  fl_chart: ^1.2.0          # Charts & graphs
  intl: ^0.20.2             # Internationalization
```

## 🔧 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

##  Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 👤 Author
**TEAM: Gate Smasher"
**Shayan Ahmad**
** Ali Haider**
- GitHub: [@shayanahmad756](https://github.com/shayanahmad756)
- GitHub: [@ali-haider1234](https://github.com/ali-haider1234)

##  Acknowledgments

- [Flutter](https://flutter.dev/) — Amazing cross-platform framework
- [fl_chart](https://github.com/imaNNeo/fl_chart) — Beautiful charting library
- Material Design 3 guidelines

---

⭐ **If you found this project helpful, please consider giving it a star!**
