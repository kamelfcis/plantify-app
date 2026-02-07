import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final double size;
  final double spacing;

  const AnimatedIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.size = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: index == currentIndex ? size * 2.5 : size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      ),
    );
  }
}

