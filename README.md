# 🌱 Plant Care & Marketplace App

A premium Flutter application for AI-powered plant identification, care management, and marketplace.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase)

## ✨ Features

- 🌱 **AI Plant Identification** - Identify any plant instantly with AI
- 🔍 **Smart Diagnosis** - Get personalized plant health diagnosis
- 💧 **Water Calculator** - Calculate optimal watering schedules
- 📅 **Care Reminders** - Never forget to water your plants
- 🛒 **Marketplace** - Buy beautiful plants online
- 🎁 **Gift Plants** - Send plants as thoughtful gifts
- 📊 **Growth Tracking** - Track your plants' growth over time
- 👤 **User Profile** - Manage orders, gifts, and preferences

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd plant-care-marketplace
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a project at [supabase.com](https://supabase.com)
   - Update `lib/core/constants/app_constants.dart` with your credentials
   - Run SQL scripts in Supabase Dashboard:
     - `supabase/schema.sql`
     - `supabase/storage.sql`

4. **Add Assets (Optional)**
   - Download Lottie animations from [LottieFiles](https://lottiefiles.com)
   - Place in `assets/lottie/` directory

5. **Run the app**
   ```bash
   flutter run
   ```

## 📚 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 minutes
- **[Setup Guide](SETUP.md)** - Detailed setup instructions
- **[Development Guide](DEVELOPMENT.md)** - Development workflow and best practices
- **[Deployment Guide](DEPLOYMENT.md)** - Production deployment checklist
- **[Project Summary](PROJECT_SUMMARY.md)** - Complete feature overview

## 🛠️ Tech Stack

- **Flutter** - UI Framework
- **Riverpod** - State Management
- **Supabase** - Backend (Auth + Database + Storage)
- **Lottie** - Animations
- **go_router** - Navigation
- **Google Fonts** - Typography
- **fl_chart** - Charts
- **flutter_form_builder** - Forms

## 📁 Project Structure

```
lib/
├── core/              # Core functionality
│   ├── config/       # App configuration
│   ├── constants/    # Constants
│   ├── providers/    # Riverpod providers
│   ├── theme/        # Theme & colors
│   ├── utils/        # Utility functions
│   └── widgets/      # Reusable widgets
├── features/         # Feature modules
│   ├── auth/        # Authentication
│   ├── onboarding/  # Onboarding
│   ├── home/        # Home dashboard
│   ├── my_plants/   # Plant tracking
│   ├── marketplace/ # Shopping
│   └── profile/     # User profile
└── services/        # Services
    ├── supabase_service.dart
    ├── ai_service.dart
    └── notification_service.dart
```

## 🎨 Design System

- **Primary Color**: #DF939D
- **Secondary Color**: #E3BBBC
- **Background**: #F1EDE1
- **Accent**: #8D9A64
- **Fonts**: Playfair Display (headings), Poppins (body)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web (partial)

## 🔧 Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development guide.

### Verify Setup
```bash
dart scripts/verify_setup.dart
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📦 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
flutter build ipa --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linter
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev)
- [Supabase](https://supabase.com)
- [LottieFiles](https://lottiefiles.com)
- [Google Fonts](https://fonts.google.com)

## 📞 Support

For issues, questions, or contributions, please open an issue on GitHub.

---

Made with ❤️ using Flutter

