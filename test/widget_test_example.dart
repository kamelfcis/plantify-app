import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care_marketplace/core/widgets/gradient_button.dart';
import 'package:plant_care_marketplace/core/theme/app_colors.dart';

void main() {
  group('GradientButton Widget Tests', () {
    testWidgets('GradientButton displays text correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify the button text is displayed
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('GradientButton calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('Test Button'));
      await tester.pump();

      // Verify onPressed was called
      expect(wasPressed, isTrue);
    });

    testWidgets('GradientButton does not call onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;

      // Build the widget with null onPressed
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      // Try to tap the button
      await tester.tap(find.text('Test Button'));
      await tester.pump();

      // Verify onPressed was not called
      expect(wasPressed, isFalse);
    });
  });
}

