# Plant Care & Marketplace App - Setup Guide

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Supabase account
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (IDE)

## Step 1: Clone and Install Dependencies

```bash
# Install Flutter dependencies
flutter pub get

# Generate code (for Riverpod)
flutter pub run build_runner build
```

## Step 2: Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Project Settings > API
3. Copy your Project URL and anon key
4. Update `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## Step 3: Run Supabase SQL Scripts

1. Open your Supabase Dashboard
2. Go to SQL Editor
3. Run `supabase/schema.sql` first
4. Then run `supabase/storage.sql`

## Step 4: Add Assets

Create the following directories and add your assets:

```
assets/
├── lottie/
│   ├── plant_identification.json
│   ├── plant_care.json
│   └── marketplace.json
├── images/
│   └── logo.png
└── icons/
```

### Lottie Animations

You can download free Lottie animations from:
- [LottieFiles](https://lottiefiles.com)
- Search for: "plant", "nature", "shopping"

Recommended animations:
- Plant identification: Search "plant" or "leaf"
- Plant care: Search "watering" or "garden"
- Marketplace: Search "shopping" or "cart"

## Step 5: Add Fonts (Optional)

If you want to use custom fonts, download:
- Playfair Display from [Google Fonts](https://fonts.google.com/specimen/Playfair+Display)
- Poppins from [Google Fonts](https://fonts.google.com/specimen/Poppins)

Place them in `assets/fonts/` and update `pubspec.yaml` if needed.

Note: The app uses `google_fonts` package, so fonts will be loaded automatically if you have internet connection.

## Step 6: Configure Notifications

### Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add notification permissions (already handled by the package)

### iOS

1. Open `ios/Runner/Info.plist`
2. Add notification permissions if needed

## Step 7: Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## Step 8: Test Features

1. **Onboarding**: First launch should show onboarding screens
2. **Authentication**: Sign up with a test email
3. **Home Dashboard**: Test AI identification and diagnosis
4. **My Plants**: Add a plant and track growth
5. **Marketplace**: Browse products and add to cart
6. **Profile**: View orders and settings

## Troubleshooting

### Supabase Connection Issues
- Verify your Supabase URL and anon key
- Check if RLS policies are correctly set
- Ensure your Supabase project is active

### Lottie Animation Not Showing
- Check if JSON files are in `assets/lottie/`
- Verify `pubspec.yaml` includes the assets
- Run `flutter clean` and `flutter pub get`

### Build Errors
- Run `flutter clean`
- Delete `pubspec.lock`
- Run `flutter pub get`
- Run `flutter pub run build_runner build --delete-conflicting-outputs`

## Project Structure

```
lib/
├── core/              # Theme, constants, reusable widgets
├── features/          # Feature modules
│   ├── auth/         # Authentication
│   ├── onboarding/   # Onboarding screens
│   ├── home/         # Home dashboard
│   ├── my_plants/    # Plant tracking
│   ├── marketplace/  # Shopping & checkout
│   └── profile/      # User profile
├── services/          # Supabase, AI, Notifications
├── main.dart         # App entry point
└── router.dart       # Navigation configuration
```

## Next Steps

1. Replace mock AI service with real API integration
2. Add image upload functionality
3. Implement real-time notifications
4. Add analytics
5. Set up CI/CD pipeline

## Support

For issues or questions, check:
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod Documentation](https://riverpod.dev)

