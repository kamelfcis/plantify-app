# How the Reminder Alarm System Works

## 🔔 Complete Flow Overview

### 1. **User Creates Reminder**
   - User fills out the reminder form:
     - **Title**: e.g., "Water Plants"
     - **Time**: e.g., 2:10 PM
     - **Repeat**: Daily, Weekly, or Once
     - **Tips** (optional): e.g., "Water thoroughly, check soil moisture"
   - User clicks "Create Reminder"

### 2. **App Processes Reminder**
   ```
   User Input → Form Validation → Database Save → Notification Schedule
   ```

### 3. **Database Storage** (Supabase)
   - Reminder saved to `reminders` table with:
     - User ID (who created it)
     - Title
     - Scheduled time
     - Repeat frequency
     - Tips (optional)
     - Notification ID (for tracking)
   - Data persists even if app is closed

### 4. **Notification Scheduling** (Local Device)
   - App schedules a local notification on the device
   - Uses device's timezone
   - Notification ID stored in database for tracking

### 5. **When Reminder Time Arrives**
   - Device's notification system triggers the alarm
   - **Sound plays** (system default notification sound)
   - **Device vibrates**
   - **Notification appears** with:
     - Title: User's reminder title
     - Body: "💡 Tip: [user's tips]" or default message

## 📱 Technical Details

### Notification Scheduling Modes

#### **Once** (One-time reminder)
- Schedules notification for specific date/time
- Fires once and done
- Example: "Water plants tomorrow at 2 PM"

#### **Daily** (Repeating daily)
- Schedules notification to repeat every day at the same time
- Uses `matchDateTimeComponents: DateTimeComponents.time`
- Example: "Water plants every day at 2 PM"

#### **Weekly** (Repeating weekly)
- Schedules notification to repeat every week on the same day/time
- Uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`
- Example: "Fertilize plants every Monday at 10 AM"

### Notification Features

#### **Sound**
- ✅ Plays system default notification sound
- ✅ Works even when device is on silent (if notification channel allows)
- ✅ High priority ensures sound plays

#### **Vibration**
- ✅ Device vibrates when notification arrives
- ✅ Helps user notice even if sound is off

#### **Display**
- ✅ Shows in notification tray
- ✅ Appears on lock screen
- ✅ Shows in notification center
- ✅ Displays tips if user provided them

### Scheduling Mode: Inexact Allow While Idle

The app uses **`inexactAllowWhileIdle`** mode:
- ✅ **No special permissions required** (works on all Android versions)
- ✅ **Works when device is idle** (screen off, doze mode)
- ✅ **Reliable delivery** (within 1-2 minutes of scheduled time)
- ✅ **Battery efficient** (system optimizes delivery)

**Note**: Notifications may arrive slightly before or after exact time (usually within 1-2 minutes), which is perfect for plant care reminders.

## 🔄 Complete Flow Diagram

```
┌─────────────────┐
│  User Creates   │
│    Reminder     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Form Validates │
│  & Submits      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Save to Supabase│
│   Database      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Schedule Local  │
│  Notification   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Device Stores  │
│  Notification   │
│  in System      │
└─────────────────┘
         │
         │ (Time passes...)
         │
         ▼
┌─────────────────┐
│  Scheduled Time │
│     Arrives     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  System Triggers│
│   Notification  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  🔔 Sound Plays │
│  📳 Vibrates    │
│  📱 Shows Alert │
│  💡 Shows Tips  │
└─────────────────┘
```

## 🎯 Key Components

### 1. **NotificationService** (`lib/services/notification_service.dart`)
   - Handles all notification operations
   - Schedules notifications
   - Manages notification channels
   - Initializes timezone

### 2. **SupabaseService** (`lib/services/supabase_service.dart`)
   - Saves reminders to database
   - Retrieves user's reminders
   - Links notification IDs to database records

### 3. **RemindersCard** (`lib/features/home/presentation/pages/widgets/reminders_card.dart`)
   - UI for creating reminders
   - Form validation
   - Calls both services to save and schedule

## 🔧 How It Works Behind the Scenes

### Step-by-Step Code Flow

1. **User fills form and clicks "Create Reminder"**
   ```dart
   _createReminder() // Called
   ```

2. **Form data extracted**
   ```dart
   title = formData['title']
   time = formData['time'] // TimeOfDay
   repeat = formData['repeat']
   tips = formData['tips']
   ```

3. **Notification scheduled**
   ```dart
   notificationId = await NotificationService.instance.scheduleReminder(
     title: title,
     time: time,
     repeat: repeat,
     tips: tips,
   )
   ```

4. **Notification service calculates scheduled time**
   ```dart
   scheduledDate = DateTime(year, month, day, hour, minute)
   if (scheduledDate.isBefore(now)) {
     scheduledDate = scheduledDate.add(Duration(days: 1)) // Tomorrow
   }
   ```

5. **Notification scheduled with device**
   ```dart
   _notifications.zonedSchedule(
     notificationId,
     title,
     body, // "💡 Tip: [tips]"
     tzScheduledDate,
     notificationDetails,
     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
   )
   ```

6. **Saved to database**
   ```dart
   reminder = await SupabaseService.instance.createReminder(...)
   await SupabaseService.instance.updateReminderNotificationId(
     reminder['id'],
     notificationId,
   )
   ```

## ⚙️ Notification Settings

### Android Notification Channel
- **Channel ID**: `plant_reminders`
- **Channel Name**: "Plant Care Reminders"
- **Importance**: High
- **Sound**: Enabled
- **Vibration**: Enabled

### iOS Notification Settings
- **Alert**: Enabled
- **Badge**: Enabled
- **Sound**: Default system sound

## 🎨 Notification Appearance

### When Notification Arrives:

```
┌─────────────────────────────┐
│  🔔 Plant Care              │
│                             │
│  Water Plants               │
│  💡 Tip: Water thoroughly, │
│     check soil moisture     │
│                             │
│  [Tap to open app]          │
└─────────────────────────────┘
```

## ✅ Benefits of This System

1. **Persistent**: Reminders saved in database
2. **Reliable**: Works even when app is closed
3. **Informative**: Shows user's care tips
4. **Accessible**: Sound + vibration + visual
5. **Flexible**: Daily, weekly, or one-time
6. **No Permissions**: Works without special permissions

## 🔍 Troubleshooting

### Notification Not Appearing?
- Check device notification settings
- Ensure app has notification permission
- Verify reminder was created successfully
- Check if device is in Do Not Disturb mode

### Sound Not Playing?
- Check device volume
- Check notification channel settings
- Verify device isn't on silent (if channel requires sound)

### Tips Not Showing?
- Verify tips were entered in the form
- Check notification body in code
- Ensure tips field exists in database

## 📝 Summary

The alarm system works by:
1. **Saving** reminder to database (persistent storage)
2. **Scheduling** local notification on device (system-level)
3. **Triggering** when time arrives (automatic)
4. **Displaying** with sound, vibration, and tips (user-friendly)

It's a hybrid system combining:
- **Cloud storage** (Supabase) for persistence
- **Local notifications** (device) for reliability
- **User tips** for helpful reminders

The system is designed to be reliable, user-friendly, and work even when the app is closed! 🎉







