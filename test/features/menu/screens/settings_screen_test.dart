import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakes_fight/core/models/game_difficulty.dart';
import 'package:snakes_fight/core/services/settings_service.dart';
import 'package:snakes_fight/features/menu/screens/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    late SettingsService settingsService;
    
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });
    
    testWidgets('should display settings sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check section headers
      expect(find.text('Audio & Haptics'), findsOneWidget);
      expect(find.text('Gameplay'), findsOneWidget);
      
      // Check setting items
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);
      expect(find.text('Difficulty'), findsOneWidget);
    });
    
    testWidgets('should display current sound setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show sound enabled by default
      final soundSwitch = tester.widget<Switch>(
        find.descendant(
          of: find.widgetWithText(SwitchListTile, 'Sound Effects'),
          matching: find.byType(Switch),
        ),
      );
      
      expect(soundSwitch.value, true);
    });
    
    testWidgets('should toggle sound setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap sound switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Sound Effects'));
      await tester.pumpAndSettle();
      
      // Check that setting was updated
      expect(settingsService.soundEnabled, false);
      
      // Check UI reflects change
      final soundSwitch = tester.widget<Switch>(
        find.descendant(
          of: find.widgetWithText(SwitchListTile, 'Sound Effects'),
          matching: find.byType(Switch),
        ),
      );
      
      expect(soundSwitch.value, false);
    });
    
    testWidgets('should toggle vibration setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap vibration switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Vibration'));
      await tester.pumpAndSettle();
      
      // Check that setting was updated
      expect(settingsService.vibrationEnabled, false);
    });
    
    testWidgets('should display difficulty segmented button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check difficulty options
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget); 
      expect(find.text('Hard'), findsOneWidget);
      
      // Normal should be selected by default
      final segmentedButton = tester.widget<SegmentedButton<GameDifficulty>>(
        find.byType(SegmentedButton<GameDifficulty>),
      );
      
      expect(segmentedButton.selected, contains(GameDifficulty.normal));
    });
    
    testWidgets('should change difficulty setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap Easy difficulty
      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();
      
      // Check that setting was updated
      expect(settingsService.difficulty, GameDifficulty.easy);
      
      // Tap Hard difficulty
      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();
      
      // Check that setting was updated
      expect(settingsService.difficulty, GameDifficulty.hard);
    });
    
    testWidgets('should show reset dialog when reset button is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap reset button
      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Reset Settings'), findsOneWidget);
      expect(
        find.text('Are you sure you want to reset all settings to their default values?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
    
    testWidgets('should reset settings when confirmed', (tester) async {
      // Change settings first
      await settingsService.setSoundEnabled(false);
      await settingsService.setVibrationEnabled(false);
      await settingsService.setDifficulty(GameDifficulty.hard);
      
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap reset button
      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();
      
      // Confirm reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      
      // Check settings were reset
      expect(settingsService.soundEnabled, true);
      expect(settingsService.vibrationEnabled, true);
      expect(settingsService.difficulty, GameDifficulty.normal);
      
      // Check snackbar is shown
      expect(find.text('Settings reset to defaults'), findsOneWidget);
    });
    
    testWidgets('should cancel reset when cancel is pressed', (tester) async {
      // Change settings first
      await settingsService.setSoundEnabled(false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(settingsService: settingsService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap reset button
      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();
      
      // Cancel reset
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Settings should not be reset
      expect(settingsService.soundEnabled, false);
    });
    
    testWidgets('should handle null settings service gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(settingsService: null),
        ),
      );
      
      await tester.pump();
      
      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should create settings service if not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should eventually show settings content
      expect(find.text('Audio & Haptics'), findsOneWidget);
      expect(find.text('Gameplay'), findsOneWidget);
    });
    
    group('Icon Tests', () {
      testWidgets('should show correct icons for sound states', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsScreen(settingsService: settingsService),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Should show volume_up icon when sound is enabled
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
        
        // Toggle sound off
        await tester.tap(find.widgetWithText(SwitchListTile, 'Sound Effects'));
        await tester.pumpAndSettle();
        
        // Should show volume_off icon when sound is disabled
        expect(find.byIcon(Icons.volume_off), findsOneWidget);
      });
      
      testWidgets('should show correct icons for vibration states', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsScreen(settingsService: settingsService),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Should show vibration icon when enabled
        expect(find.byIcon(Icons.vibration), findsOneWidget);
        
        // Toggle vibration off
        await tester.tap(find.widgetWithText(SwitchListTile, 'Vibration'));
        await tester.pumpAndSettle();
        
        // Should show phone icon when disabled
        expect(find.byIcon(Icons.phone_android), findsOneWidget);
      });
    });
  });
}
