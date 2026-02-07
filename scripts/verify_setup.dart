#!/usr/bin/env dart
// Run with: dart scripts/verify_setup.dart

import 'dart:io';

void main() {
  print('🔍 Verifying Plant Care App Setup...\n');

  bool allGood = true;

  // Check pubspec.yaml
  print('📦 Checking pubspec.yaml...');
  if (File('pubspec.yaml').existsSync()) {
    print('   ✅ pubspec.yaml exists');
  } else {
    print('   ❌ pubspec.yaml not found');
    allGood = false;
  }

  // Check main.dart
  print('\n📱 Checking main.dart...');
  if (File('lib/main.dart').existsSync()) {
    print('   ✅ main.dart exists');
  } else {
    print('   ❌ main.dart not found');
    allGood = false;
  }

  // Check core directories
  print('\n📁 Checking core directories...');
  final coreDirs = [
    'lib/core/theme',
    'lib/core/widgets',
    'lib/core/constants',
    'lib/core/utils',
  ];
  for (var dir in coreDirs) {
    if (Directory(dir).existsSync()) {
      print('   ✅ $dir exists');
    } else {
      print('   ❌ $dir not found');
      allGood = false;
    }
  }

  // Check feature directories
  print('\n📁 Checking feature directories...');
  final featureDirs = [
    'lib/features/auth',
    'lib/features/onboarding',
    'lib/features/home',
    'lib/features/my_plants',
    'lib/features/marketplace',
    'lib/features/profile',
  ];
  for (var dir in featureDirs) {
    if (Directory(dir).existsSync()) {
      print('   ✅ $dir exists');
    } else {
      print('   ❌ $dir not found');
      allGood = false;
    }
  }

  // Check services
  print('\n🔧 Checking services...');
  final services = [
    'lib/services/supabase_service.dart',
    'lib/services/ai_service.dart',
    'lib/services/notification_service.dart',
  ];
  for (var service in services) {
    if (File(service).existsSync()) {
      print('   ✅ ${service.split('/').last} exists');
    } else {
      print('   ❌ ${service.split('/').last} not found');
      allGood = false;
    }
  }

  // Check Supabase SQL files
  print('\n🗄️ Checking Supabase SQL files...');
  final sqlFiles = [
    'supabase/schema.sql',
    'supabase/storage.sql',
  ];
  for (var file in sqlFiles) {
    if (File(file).existsSync()) {
      print('   ✅ ${file.split('/').last} exists');
    } else {
      print('   ❌ ${file.split('/').last} not found');
      allGood = false;
    }
  }

  // Check assets directories
  print('\n🎨 Checking assets directories...');
  final assetDirs = [
    'assets/lottie',
    'assets/images',
    'assets/icons',
  ];
  for (var dir in assetDirs) {
    if (Directory(dir).existsSync()) {
      print('   ✅ $dir exists');
    } else {
      print('   ⚠️  $dir not found (optional)');
    }
  }

  // Summary
  print('\n' + '=' * 50);
  if (allGood) {
    print('✅ Setup verification PASSED!');
    print('\n📝 Next steps:');
    print('   1. Run: flutter pub get');
    print('   2. Configure Supabase credentials');
    print('   3. Run Supabase SQL scripts');
    print('   4. Add Lottie animations (optional)');
    print('   5. Run: flutter run');
  } else {
    print('❌ Setup verification FAILED!');
    print('   Please check the errors above.');
  }
  print('=' * 50);
}

