# Development Guide

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Initial Setup
```bash
# Clone the repository (if applicable)
# cd to project directory

# Install dependencies
flutter pub get

# Generate code (for Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Verify setup
dart scripts/verify_setup.dart
```

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── constants/          # Constants
│   ├── providers/          # Riverpod providers
│   ├── theme/              # Theme & colors
│   ├── utils/              # Utility functions
│   └── widgets/             # Reusable widgets
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── onboarding/         # Onboarding
│   ├── home/               # Home dashboard
│   ├── my_plants/          # Plant tracking
│   ├── marketplace/        # Shopping
│   └── profile/            # User profile
└── services/               # Services
    ├── supabase_service.dart
    ├── ai_service.dart
    └── notification_service.dart
```

## 🔧 Development Workflow

### Running the App
```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release

# Run with hot reload enabled (default)
flutter run --hot
```

### Code Generation
```bash
# Generate Riverpod code
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/example_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Fix linter issues
dart fix --apply
```

## 🎨 UI Development

### Using Theme
```dart
// Access theme colors
AppColors.primary
AppColors.secondary

// Access theme in widget
Theme.of(context).textTheme.headlineMedium
```

### Using Reusable Widgets
```dart
// Gradient Button
GradientButton(
  text: 'Click Me',
  onPressed: () {},
)

// Glass Card
GlassCard(
  child: YourContent(),
)

// Loading Overlay
LoadingOverlay(
  isLoading: true,
  child: YourContent(),
)
```

### Using Extensions
```dart
// String extensions
'hello world'.capitalizeWords() // 'Hello World'

// Context extensions
context.screenWidth
context.screenHeight
context.isDarkMode
```

## 🔌 Service Integration

### Supabase
```dart
// Get Supabase client
final client = SupabaseService.instance.client;

// Check auth state
final isAuth = SupabaseService.instance.isAuthenticated;

// Get current user
final user = SupabaseService.instance.currentUser;
```

### Notifications
```dart
// Schedule reminder
await NotificationService.instance.scheduleReminder(
  title: 'Water Plants',
  time: TimeOfDay.now(),
  repeat: 'Daily',
);
```

### Storage
```dart
// Save data
await StorageHelper.setString('key', 'value');

// Get data
final value = await StorageHelper.getString('key');
```

## 🐛 Debugging

### Logging
```dart
// Use AppLogger
AppLogger.debug('Debug message');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', error, stackTrace);
AppLogger.success('Success message');
```

### Common Issues

**Issue: Supabase connection fails**
- Check credentials in `app_constants.dart`
- Verify Supabase project is active
- Check network connection

**Issue: Lottie animations not showing**
- Verify JSON files in `assets/lottie/`
- Check `pubspec.yaml` includes assets
- Run `flutter clean && flutter pub get`

**Issue: Build errors**
- Run `flutter clean`
- Delete `pubspec.lock`
- Run `flutter pub get`
- Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue: Navigation not working**
- Check router configuration
- Verify route paths match
- Check authentication state

## 📝 Code Style

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

### File Organization
- One class per file
- Group related files in folders
- Use feature-based structure

### Best Practices
- Use const constructors when possible
- Extract widgets for reusability
- Use meaningful variable names
- Add comments for complex logic
- Handle errors gracefully

## 🚀 Performance Tips

1. **Use const widgets** where possible
2. **Lazy load** heavy data
3. **Cache images** with cached_network_image
4. **Optimize builds** with build_runner
5. **Profile performance** with Flutter DevTools

## 📦 Adding New Features

1. Create feature folder in `lib/features/`
2. Add presentation, domain, data layers (if needed)
3. Create models if needed
4. Add routes in `router.dart`
5. Update navigation if needed
6. Add tests

## 🔐 Security

- Never commit API keys
- Use environment variables
- Validate user input
- Use RLS policies in Supabase
- Sanitize data before display

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Run tests
4. Run linter
5. Submit pull request

## 📞 Support

For issues or questions:
- Check existing documentation
- Review code comments
- Check Flutter/Supabase docs
- Open an issue (if applicable)

