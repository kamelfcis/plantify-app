# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Supabase
1. Create account at [supabase.com](https://supabase.com)
2. Create a new project
3. Copy your project URL and anon key
4. Update `lib/core/constants/app_constants.dart`:
   ```dart
   static const String supabaseUrl = 'https://your-project.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key';
   ```

### 3. Set Up Database
1. Open Supabase Dashboard → SQL Editor
2. Run `supabase/schema.sql`
3. Run `supabase/storage.sql`

### 4. Add Lottie Animations (Optional)
Download free animations from [LottieFiles](https://lottiefiles.com):
- `plant_identification.json` → `assets/lottie/`
- `plant_care.json` → `assets/lottie/`
- `marketplace.json` → `assets/lottie/`

### 5. Run the App
```bash
flutter run
```

## ✨ Features Ready to Use

- ✅ Onboarding screens
- ✅ User authentication
- ✅ AI plant identification (mock)
- ✅ Plant diagnosis (mock)
- ✅ Water calculator
- ✅ Care reminders
- ✅ Plant tracking
- ✅ Marketplace
- ✅ Shopping cart
- ✅ Gift orders
- ✅ User profile

## 📱 Test the App

1. **First Launch**: See onboarding screens
2. **Sign Up**: Create a test account
3. **Home**: Try AI identification and diagnosis
4. **My Plants**: Add a plant and track growth
5. **Marketplace**: Browse and add to cart
6. **Profile**: View orders and settings

## 🎨 Customization

### Change Colors
Edit `lib/core/theme/app_colors.dart`

### Change Fonts
Fonts are loaded from Google Fonts automatically. To use local fonts, update `pubspec.yaml`.

### Add Real AI
Replace mock responses in `lib/services/ai_service.dart` with your AI API.

## 🐛 Troubleshooting

**App won't start?**
- Check Supabase credentials
- Run `flutter clean && flutter pub get`

**Lottie animations not showing?**
- Add JSON files to `assets/lottie/`
- Check `pubspec.yaml` includes assets

**Database errors?**
- Verify SQL scripts ran successfully
- Check RLS policies in Supabase dashboard

## 📚 Documentation

- Full setup: See `SETUP.md`
- Project structure: See `PROJECT_SUMMARY.md`
- Supabase docs: https://supabase.com/docs

Happy coding! 🌱

