import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/design_system/design_tokens.dart';
import 'package:snakes_fight/shared/components/components.dart';

void main() {
  group('Responsive UI Design System Tests', () {
    testWidgets('AppButton renders with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('AppButton variants work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppButton.primary(text: 'Primary', onPressed: () {}),
                AppButton.secondary(text: 'Secondary', onPressed: () {}),
                AppButton.outline(text: 'Outline', onPressed: () {}),
                AppButton.text(text: 'Text', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('AppTextField renders with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              labelText: 'Test Field',
              hintText: 'Enter text',
            ),
          ),
        ),
      );

      expect(find.text('Test Field'), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('AppTextField email factory works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField.email(),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('AppTextField password factory works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField.password(),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('AppCard renders with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('AppCard variants work correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppCard(child: Text('Elevated')),
                AppCard.outlined(child: Text('Outlined')),
                AppCard.filled(child: Text('Filled')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Elevated'), findsOneWidget);
      expect(find.text('Outlined'), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
    });

    testWidgets('AppBadge renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(
              text: 'Badge',
            ),
          ),
        ),
      );

      expect(find.text('Badge'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('AppLoadingIndicator renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingIndicator(
              message: 'Loading...',
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppLoadingIndicator sizes work correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppLoadingIndicator.small(),
                AppLoadingIndicator(),
                AppLoadingIndicator.large(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
    });

    test('DesignTokens contains required values', () {
      // Test color schemes
      expect(DesignTokens.lightColorScheme, isA<ColorScheme>());
      expect(DesignTokens.darkColorScheme, isA<ColorScheme>());
      
      // Test spacing tokens
      expect(DesignTokens.spacing8, equals(8.0));
      expect(DesignTokens.spacing16, equals(16.0));
      expect(DesignTokens.spacing24, equals(24.0));
      
      // Test animation tokens
      expect(DesignTokens.fastAnimation, equals(const Duration(milliseconds: 150)));
      expect(DesignTokens.normalAnimation, equals(const Duration(milliseconds: 300)));
      
      // Test border radius tokens
      expect(DesignTokens.radiusSmall, equals(8.0));
      expect(DesignTokens.radiusMedium, equals(12.0));
      expect(DesignTokens.radiusLarge, equals(16.0));
      
      // Test elevation tokens
      expect(DesignTokens.elevation0, equals(0.0));
      expect(DesignTokens.elevation1, equals(1.0));
      expect(DesignTokens.elevation2, equals(3.0));
      
      // Test icon sizes
      expect(DesignTokens.iconSmall, equals(20.0));
      expect(DesignTokens.iconMedium, equals(24.0));
      expect(DesignTokens.iconLarge, equals(32.0));
    });

    test('Button and Badge enums work correctly', () {
      expect(AppButtonStyle.values.length, equals(4));
      expect(AppButtonSize.values.length, equals(3));
      expect(AppBadgeSize.values.length, equals(3));
      expect(AppBadgeVariant.values.length, equals(2));
      expect(AppCardVariant.values.length, equals(3));
      expect(AppLoadingSize.values.length, equals(3));
    });
  });
}
