# Notification Troubleshooting Guide

## 🔍 Why Notifications Might Not Work

### Common Issues & Solutions

#### 1. **Notification Permissions Not Granted**
**Problem**: App doesn't have permission to show notifications

**Solution**:
- Go to **Settings** → **Apps** → **Plant Care** → **Notifications**
- Make sure notifications are **enabled**
- Check that "Plant Care Reminders" channel is enabled
- **Note**: The notification channel is created automatically by the app - you don't need to create it in Supabase or anywhere else. It's created when the app starts.

#### 2. **Battery Optimization**
**Problem**: Device kills the app in background

**Solution**:
- Go to **Settings** → **Battery** → **Battery Optimization**
- Find "Plant Care" app
- Set to **"Don't optimize"** or **"Not optimized"**

#### 3. **Do Not Disturb Mode**
**Problem**: Device is in Do Not Disturb mode

**Solution**:
- Check if Do Not Disturb is enabled
- Go to **Settings** → **Sound** → **Do Not Disturb**
- Either disable it or allow Plant Care notifications

#### 4. **App Not Running**
**Problem**: App was force-closed

**Solution**:
- Keep the app in background (don't force close)
- Or restart the app before reminder time

#### 5. **Time Zone Issues**
**Problem**: Notification scheduled in wrong timezone

**Solution**: 
- The app now uses device timezone automatically
- Check device timezone settings are correct

#### 6. **Inexact Scheduling**
**Problem**: Notification may arrive 1-2 minutes early/late

**Solution**:
- This is normal for inexact scheduling
- Notifications will arrive within 1-2 minutes of scheduled time
- This is acceptable for plant care reminders

## 🧪 Testing Notifications

### Method 1: Test Notification (5 seconds)
The app now has a test notification feature. Check the debug logs to see if it's available.

### Method 2: Create Test Reminder
1. Create a reminder for **1-2 minutes from now**
2. Wait and see if notification appears
3. Check debug logs in console

### Method 3: Check Pending Notifications
After creating a reminder, check the debug console:
```
📋 Total pending notifications: X
   - ID: 12345, Title: Water Plants, Body: ...
```

## 📱 Device-Specific Settings

### Android 12+ (API 31+)
- Notifications should work automatically
- Check notification channel settings
- Ensure app has notification permission

### Android 11 and Below
- Check notification settings
- Ensure app is not battery optimized
- Check if notifications are enabled for the app

## 🔧 Debug Steps

### Step 1: Check Debug Logs
When you create a reminder, you should see:
```
📅 Scheduling reminder:
   Title: Water Plants
   Time: 14:10
   Repeat: Daily
   Scheduled Date: 2024-01-15 14:10:00
   TZ Date: 2024-01-15 14:10:00
   Location: UTC
   Current Time: 2024-01-15 13:00:00
✅ Notification scheduled (Daily) with ID: 12345
```

### Step 2: Verify Notification is Scheduled
After creating reminder, check logs:
```
📋 Total pending notifications: 1
   - ID: 12345, Title: Water Plants, Body: 💡 Tip: ...
```

### Step 3: Check Device Settings
1. Settings → Apps → Plant Care → Notifications
2. Ensure "Plant Care Reminders" channel is enabled
3. Check importance is set to "High"

### Step 4: Test with Immediate Reminder
1. Create reminder for 1-2 minutes from now
2. Keep app open or in background
3. Wait for notification
4. Check if it appears

## ✅ Verification Checklist

- [ ] App has notification permission
- [ ] Notification channel is enabled
- [ ] Battery optimization is disabled for app
- [ ] Do Not Disturb is not blocking notifications
- [ ] Device timezone is correct
- [ ] Reminder was created successfully (check success message)
- [ ] Debug logs show notification was scheduled
- [ ] Pending notifications list shows the reminder

## 🚨 Still Not Working?

### Check These:

1. **App Version**: Make sure you're running the latest version
2. **Device Restart**: Try restarting your device
3. **App Reinstall**: Uninstall and reinstall the app
4. **Check Logs**: Look for error messages in debug console
5. **Test Notification**: Try the test notification feature

### Common Error Messages:

- `exact_alarms_not_permitted` → Already fixed, using inexact scheduling
- `timezone not initialized` → Already fixed, timezone auto-initializes
- `notification channel not found` → Channel is created on app startup

## 📝 What to Check in Logs

When creating a reminder, look for:
- ✅ `Scheduling reminder:` - Shows reminder details
- ✅ `Notification scheduled` - Confirms scheduling
- ✅ `Total pending notifications: X` - Shows scheduled count
- ❌ Any error messages

## 🎯 Expected Behavior

1. **Create Reminder** → Success message appears
2. **Debug Logs** → Show scheduling details
3. **Pending Notifications** → Shows in list
4. **Time Arrives** → Notification appears with sound/vibration
5. **Notification Shows** → Title and tips displayed

## 💡 Tips

- **Test First**: Create a reminder for 1-2 minutes from now to test
- **Check Settings**: Verify notification permissions before creating reminders
- **Keep App Active**: Don't force-close the app
- **Check Logs**: Debug logs show exactly what's happening
- **Be Patient**: Inexact scheduling may delay by 1-2 minutes

## 🔄 Next Steps

1. **Hot Restart** the app
2. **Create a test reminder** for 1-2 minutes from now
3. **Check debug logs** in console
4. **Wait for notification**
5. **Report any errors** you see in logs

The notification system should now work with better timezone handling and debugging! 🎉

