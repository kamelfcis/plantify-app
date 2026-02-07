import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/main_scaffold.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/my_plants/presentation/pages/my_plants_page.dart';
import 'features/marketplace/presentation/pages/marketplace_page.dart';
import 'features/marketplace/presentation/pages/product_detail_page.dart';
import 'features/marketplace/presentation/pages/cart_page.dart';
import 'features/marketplace/presentation/pages/checkout_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/order_history_page.dart';
import 'features/profile/presentation/pages/gift_history_page.dart';
import 'features/profile/presentation/pages/change_password_page.dart';
import 'features/profile/presentation/pages/personal_info_page.dart';
import 'features/reminders/presentation/pages/reminders_list_page.dart';
import 'features/plant_identification/presentation/pages/plant_identification_page.dart';
import 'features/plant_diagnosis/presentation/pages/plant_diagnosis_page.dart';
import 'features/chatbot/presentation/pages/chatbot_page.dart';
import 'features/admin/presentation/pages/admin_login_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'services/supabase_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isAuthenticated = SupabaseService.instance.isAuthenticated;

      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuth = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';

      // Don't redirect from splash - let it handle its own navigation
      if (isSplash) {
        return null;
      }

      // Allow admin routes without Supabase auth
      final isAdmin = state.matchedLocation.startsWith('/admin');
      if (isAdmin) {
        return null;
      }

      // After onboarding, check authentication
      if (!isAuthenticated && !isAuth && !isOnboarding) {
        return '/auth/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => MainScaffold(
          currentPath: '/home',
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersListPage(),
      ),
      GoRoute(
        path: '/plant-identification',
        builder: (context, state) => const PlantIdentificationPage(),
      ),
      GoRoute(
        path: '/plant-diagnosis',
        builder: (context, state) => const PlantDiagnosisPage(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),
      GoRoute(
        path: '/my-plants',
        builder: (context, state) => MainScaffold(
          currentPath: '/my-plants',
          child: const MyPlantsPage(),
        ),
      ),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => MainScaffold(
          currentPath: '/marketplace',
          child: const MarketplacePage(),
        ),
      ),
      GoRoute(
        path: '/marketplace/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),
      GoRoute(
        path: '/marketplace/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/marketplace/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => MainScaffold(
          currentPath: '/profile',
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/orders',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: '/profile/gifts',
        builder: (context, state) => const GiftHistoryPage(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/profile/personal-info',
        builder: (context, state) => const PersonalInfoPage(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
  );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse controller (repeating)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Fade animation for logo
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Scale animation with bounce
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Pulse animation (continuous)
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Text fade animation (starts after logo)
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // Start main animation
    _mainController.forward();

    // Navigate after animation completes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: Listenable.merge([_mainController, _pulseController]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4 * _fadeAnimation.value),
                              blurRadius: 30 * _scaleAnimation.value,
                              offset: Offset(0, 10 * _scaleAnimation.value),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Animated Text
              FadeTransition(
                opacity: _textFadeAnimation,
                child: AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
                      child: Text(
                        'Plant Care',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Animated Loading Indicator
              FadeTransition(
                opacity: _textFadeAnimation,
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

