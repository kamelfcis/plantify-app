# Permission Request Setup

## ✅ What Was Added

### 1. **Permission Service** (`lib/services/permission_service.dart`)
- Handles notification and alarm permission requests
- Shows a beautiful permission dialog on first app launch
- Tracks if permissions have been requested (using SharedPreferences)
- Only asks once (first time)

### 2. **Permission Dialog**
- Beautiful UI explaining why permissions are needed
- Shows status of each permission (notification, alarm)
- "Allow" button to request all permissions
- "Maybe Later" option to skip

### 3. **Integration**
- Permission dialog shows after onboarding completes
- Only shows on first app launch
- Automatically requests both notification and alarm permissions

## 📱 Permissions Requested

### 1. **Notification Permission**
- Required for: Receiving reminders for watering, fertilizing, and plant care
- Android 13+: Runtime permission request
- iOS: Requested via notification service

### 2. **Alarm Permission**
- Required for: Scheduling exact reminders at specific times
- Android 12+: `SCHEDULE_EXACT_ALARM` permission
- Allows precise timing for reminders

## 🔧 How It Works

### Flow:
1. User completes onboarding
2. App checks if permissions have been requested before
3. If not requested:
   - Shows permission dialog
   - User clicks "Allow"
   - App requests notification permission
   - App requests alarm permission
   - Marks permissions as requested
4. User continues to login/home

### Code Flow:
```dart
// In onboarding_page.dart
Future<void> _completeOnboarding() async {
  // Check if permissions requested
  final hasRequested = await PermissionService.instance.hasRequestedPermissions();
  
  // Show dialog if not requested
  if (!hasRequested) {
    await PermissionService.instance.showPermissionDialog(context);
  }
  
  // Navigate to next screen
  context.go('/home');
}
```

## 🎨 Permission Dialog Features

- **Title**: "Enable Notifications & Alarms"
- **Description**: Explains why permissions are needed
- **Permission Items**:
  - Notifications: "Receive reminders for watering, fertilizing, and plant care"
  - Alarms: "Schedule exact reminders at specific times"
- **Status Indicators**: Shows checkmark when permission is granted
- **Actions**:
  - "Maybe Later": Skip permission request
  - "Allow": Request all permissions

## 📋 Dependencies Added

```yaml
permission_handler: ^11.3.0
```

This package handles:
- Runtime permission requests
- Permission status checks
- Android 13+ notification permissions
- Alarm permissions

## 🚀 Testing

### To Test:
1. **Uninstall and reinstall** the app (to reset permissions)
2. **Run the app** for the first time
3. **Complete onboarding**
4. **Permission dialog should appear**
5. **Click "Allow"**
6. **System permission dialogs should appear**
7. **Grant permissions**
8. **App should continue to login/home**

### To Test "Maybe Later":
1. Complete onboarding
2. Click "Maybe Later" on permission dialog
3. App should continue without requesting permissions
4. Dialog won't show again (until app is reinstalled)

## 🔍 Debugging

### Check Permission Status:
```dart
// Check if notification permission is granted
final notificationGranted = await PermissionService.instance.isNotificationPermissionGranted();

// Check if alarm permission is granted
final alarmGranted = await PermissionService.instance.isAlarmPermissionGranted();

// Check if permissions have been requested
final hasRequested = await PermissionService.instance.hasRequestedPermissions();
```

### Debug Logs:
Look for these in debug console:
```
🔐 Requesting all permissions...
📱 Notification permission status: granted
⏰ Alarm permission status: granted
✅ Permission request results: {notification: true, alarm: true}
```

## ⚠️ Important Notes

1. **First Time Only**: Permission dialog only shows once
2. **Android 13+**: Notification permission requires runtime request
3. **Android 12+**: Alarm permission requires runtime request
4. **iOS**: Permissions are requested via notification service
5. **Storage**: Permission request status is stored in SharedPreferences

## 🐛 Troubleshooting

### Permission Dialog Not Showing:
- Check if `hasRequestedPermissions()` returns `true`
- Clear app data: `Settings > Apps > Plant Care > Clear Data`
- Reinstall the app

### Permissions Not Granted:
- Check device settings: `Settings > Apps > Plant Care > Permissions`
- Manually enable notifications and alarms
- Check Android version (Android 12+ for alarms, Android 13+ for notifications)

### Permission Dialog Shows Every Time:
- Check SharedPreferences storage
- Verify `markPermissionsRequested()` is being called
- Check for errors in permission service

## 📝 Next Steps

1. **Test on real device** (permissions work differently on emulator)
2. **Test on different Android versions** (12, 13, 14)
3. **Test on iOS** (if applicable)
4. **Handle permission denial** (show settings page if denied)






