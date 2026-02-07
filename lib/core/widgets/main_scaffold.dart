import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'floating_chatbot_button.dart';
import '../../services/supabase_service.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with WidgetsBindingObserver {
  Timer? _lastSeenTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Update last_seen immediately and then every 2 minutes
    _updateLastSeen();
    _lastSeenTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _updateLastSeen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lastSeenTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground — mark online
      _updateLastSeen();
    }
  }

  Future<void> _updateLastSeen() async {
    try {
      await SupabaseService.instance.updateLastSeen();
    } catch (_) {
      // Silently ignore — non-critical
    }
  }
  int _getCurrentIndex() {
    switch (widget.currentPath) {
      case '/home':
        return 0;
      case '/my-plants':
        return 1;
      case '/marketplace':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/my-plants');
        break;
      case 2:
        context.go('/marketplace');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          // Floating Chatbot Button
          const Positioned(
            right: 16,
            bottom: 90, // Above the navigation bar
            child: FloatingChatbotButton(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getCurrentIndex(),
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'My Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Marketplace',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}





