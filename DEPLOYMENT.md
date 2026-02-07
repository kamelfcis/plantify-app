# Deployment Guide

## Pre-Deployment Checklist

### 1. Environment Configuration
- [ ] Update Supabase credentials in production
- [ ] Set up environment variables
- [ ] Configure API keys
- [ ] Test all Supabase connections

### 2. Code Quality
- [ ] Run `flutter analyze`
- [ ] Fix all linter warnings
- [ ] Remove debug prints
- [ ] Remove test/mock data
- [ ] Update version numbers

### 3. Assets
- [ ] Add app icons (all sizes)
- [ ] Add splash screens
- [ ] Verify all Lottie animations load
- [ ] Optimize images
- [ ] Test asset loading

### 4. Platform-Specific Setup

#### Android
- [ ] Update `android/app/build.gradle`
  - Set `versionCode` and `versionName`
  - Configure signing
- [ ] Update `AndroidManifest.xml`
  - Set proper package name
  - Configure permissions
- [ ] Generate signed APK/AAB
- [ ] Test on multiple Android versions

#### iOS
- [ ] Update `ios/Runner/Info.plist`
  - Set proper bundle identifier
  - Configure permissions
- [ ] Update `ios/Runner.xcodeproj`
  - Set version and build number
- [ ] Configure code signing
- [ ] Archive and upload to App Store Connect
- [ ] Test on multiple iOS versions

### 5. Supabase Production Setup
- [ ] Create production Supabase project
- [ ] Run migration scripts
- [ ] Set up RLS policies
- [ ] Configure storage buckets
- [ ] Set up backups
- [ ] Configure monitoring

### 6. Testing
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual testing on devices
- [ ] Test all user flows
- [ ] Test error scenarios

### 7. Security
- [ ] Review RLS policies
- [ ] Secure API keys
- [ ] Enable HTTPS only
- [ ] Review permissions
- [ ] Set up rate limiting
- [ ] Configure CORS if needed

## Build Commands

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Build with specific flavor
flutter build apk --release --flavor production
```

### iOS
```bash
# Build for iOS
flutter build ios --release

# Build IPA
flutter build ipa --release
```

### Web
```bash
# Build for web
flutter build web --release
```

## App Store Submission

### Google Play Store
1. Create app listing
2. Upload AAB file
3. Add screenshots
4. Write description
5. Set pricing
6. Submit for review

### Apple App Store
1. Create app in App Store Connect
2. Upload IPA via Xcode or Transporter
3. Add screenshots and metadata
4. Submit for review

## Post-Deployment

- [ ] Monitor crash reports
- [ ] Set up analytics
- [ ] Monitor performance
- [ ] Collect user feedback
- [ ] Plan updates

## Environment Variables

For production, use:
- `flutter_dotenv` package
- Secure storage for sensitive keys
- Environment-specific configs

## Continuous Integration

Consider setting up CI/CD with:
- GitHub Actions
- Codemagic
- Bitrise
- Fastlane

## Monitoring

Set up:
- Crash reporting (Sentry, Firebase Crashlytics)
- Analytics (Firebase Analytics, Mixpanel)
- Performance monitoring
- User feedback system

