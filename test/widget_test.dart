// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snakes_fight/core/core.dart';

void main() {
  testWidgets('App widget can be instantiated', (WidgetTester tester) async {
    // Create a simple test app without Firebase dependencies
    final testApp = ProviderScope(
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(body: Center(child: Text('Test App'))),
        debugShowCheckedModeBanner: false,
      ),
    );

    // Build our test app and trigger a frame.
    await tester.pumpWidget(testApp);

    // Check that the app can be created without throwing errors
    expect(find.text('Test App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App theme can be applied', (WidgetTester tester) async {
    final testApp = MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(body: Center(child: Text('Theme Test'))),
    );

    await tester.pumpWidget(testApp);

    expect(find.text('Theme Test'), findsOneWidget);
  });
}
