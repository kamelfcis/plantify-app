import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/animated_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/permission_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'AI Plant Identification',
      description: 'Identify any plant instantly with our advanced AI technology. Just snap a photo and get detailed information.',
      lottieAsset: 'assets/lottie/plant_identification.json',
    ),
    OnboardingData(
      title: 'Smart Diagnosis & Care',
      description: 'Get personalized care recommendations and diagnose plant health issues with expert AI guidance.',
      lottieAsset: 'assets/lottie/plant_care.json',
    ),
    OnboardingData(
      title: 'Buy or Gift Plants Easily',
      description: 'Explore our marketplace to buy beautiful plants or send them as thoughtful gifts to your loved ones.',
      lottieAsset: 'assets/lottie/marketplace.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    // Don't save onboarding completion - always show it
    if (mounted) {
      // Check if permissions have been requested
      final hasRequested = await PermissionService.instance.hasRequestedPermissions();
      
      // If not requested, show permission dialog
      if (!hasRequested) {
        final granted = await PermissionService.instance.showPermissionDialog(context);
        debugPrint('Permission dialog result: $granted');
      }
      
      // Navigate based on authentication
      final isAuthenticated = SupabaseService.instance.isAuthenticated;
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/auth/login');
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(data: _pages[index]);
                },
              ),
            ),

            // Indicators
            AnimatedIndicator(
              currentIndex: _currentPage,
              totalCount: _pages.length,
            ),

            const SizedBox(height: 32),

            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GradientButton(
                text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: _nextPage,
                width: double.infinity,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          Expanded(
            flex: 3,
            child: Lottie.asset(
              data.lottieAsset,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.local_florist,
                    size: 100,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String lottieAsset;

  OnboardingData({
    required this.title,
    required this.description,
    required this.lottieAsset,
  });
}

