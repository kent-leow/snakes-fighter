# Task 1.3.4: Create Game Menu Screens

## Task Overview
- **User Story**: us-1.3-basic-game-ui
- **Task ID**: task-1.3.4-create-game-menu-screens
- **Priority**: High
- **Estimated Effort**: 12 hours
- **Dependencies**: task-1.3.1-create-game-canvas-rendering-system, task-1.3.3-create-game-hud-score-display

## Description
Create essential game menu screens including main menu, pause menu, game over screen, and basic settings screen. These screens provide navigation, game control, and user configuration options for the complete game experience.

## Technical Requirements
### Architecture Components
- **Frontend**: Menu UI screens, navigation system, settings management
- **Backend**: None (UI screens)
- **Database**: Local storage for settings
- **Integration**: Integration with game controller and state management

### Technology Stack
- **Language/Framework**: Flutter widgets, Material Design, navigation
- **Dependencies**: Flutter material design, shared_preferences
- **Tools**: Flutter navigation system, local storage

## Implementation Steps

### Step 1: Create Main Menu Screen
- **Action**: Design and implement main menu with game title, play button, and navigation
- **Deliverable**: Attractive main menu screen with proper branding
- **Acceptance**: Professional-looking main menu with smooth navigation
- **Files**: lib/features/menu/screens/main_menu_screen.dart

### Step 2: Implement Pause Menu System
- **Action**: Create in-game pause menu with resume, restart, and main menu options
- **Deliverable**: Overlay pause menu that preserves game state
- **Acceptance**: Pause menu accessible during gameplay without state loss
- **Files**: lib/features/menu/screens/pause_menu_screen.dart

### Step 3: Create Game Over Screen
- **Action**: Design game over screen with score display, restart, and menu options
- **Deliverable**: Game over screen with score summary and action buttons
- **Acceptance**: Clear game over feedback with score and restart functionality
- **Files**: lib/features/menu/screens/game_over_screen.dart

### Step 4: Implement Basic Settings Screen
- **Action**: Create settings screen for sound, controls, and display options
- **Deliverable**: Settings screen with persistent configuration options
- **Acceptance**: Settings saved and applied across game sessions
- **Files**: lib/features/menu/screens/settings_screen.dart, lib/core/services/settings_service.dart

### Step 5: Create Navigation System
- **Action**: Implement navigation flow between all screens with proper state management
- **Deliverable**: Seamless navigation system with proper back stack management
- **Acceptance**: Smooth transitions between all screens without memory leaks
- **Files**: lib/core/navigation/app_router.dart, lib/core/navigation/navigation_service.dart

## Technical Specifications
### Main Menu Screen
```dart
class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade800, Colors.green.shade600],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGameTitle(),
              SizedBox(height: 60),
              _buildMenuButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameTitle() {
    return Text(
      'SNAKES FIGHT',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.3),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuButtons() {
    return Column(
      children: [
        _buildMenuButton('PLAY', onPressed: _startGame),
        SizedBox(height: 16),
        _buildMenuButton('SETTINGS', onPressed: _openSettings),
        SizedBox(height: 16),
        _buildMenuButton('EXIT', onPressed: _exitGame),
      ],
    );
  }
}
```

### Pause Menu Screen
```dart
class PauseMenuScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const PauseMenuScreen({
    Key? key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PAUSED',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 24),
                _buildPauseMenuButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Settings Service
```dart
class SettingsService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _difficultyKey = 'difficulty';
  
  final SharedPreferences _prefs;
  
  SettingsService(this._prefs);
  
  // Sound settings
  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }
  
  // Vibration settings
  bool get vibrationEnabled => _prefs.getBool(_vibrationEnabledKey) ?? true;
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }
  
  // Difficulty settings
  GameDifficulty get difficulty {
    final difficultyIndex = _prefs.getInt(_difficultyKey) ?? 1;
    return GameDifficulty.values[difficultyIndex];
  }
  
  Future<void> setDifficulty(GameDifficulty difficulty) async {
    await _prefs.setInt(_difficultyKey, difficulty.index);
  }
}
```

### Navigation Service
```dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static Future<void> pushReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<void> push(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }
  
  static void pop([Object? result]) {
    return navigatorKey.currentState!.pop(result);
  }
  
  static Future<void> pushAndClearStack(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
```

## Testing Requirements
- [ ] Widget tests for all menu screens
- [ ] Navigation flow tests between screens
- [ ] Settings persistence tests
- [ ] Responsive design tests on different screen sizes
- [ ] Accessibility tests for menu interactions
- [ ] Memory leak tests for navigation

## Acceptance Criteria
- [ ] Main menu displays properly with game branding
- [ ] Pause menu accessible during gameplay
- [ ] Game over screen shows final score and options
- [ ] Settings screen allows configuration changes
- [ ] Settings persist between app sessions
- [ ] Navigation between screens is smooth and intuitive
- [ ] All screens responsive on different device sizes
- [ ] Memory usage stable during navigation
- [ ] All implementation steps completed

## Dependencies
### Task Dependencies
- **Before**: task-1.3.1-create-game-canvas-rendering-system, task-1.3.3-create-game-hud-score-display
- **After**: task-1.3.5-add-basic-sound-effects, overall UI integration

### External Dependencies
- **Services**: SharedPreferences for settings storage
- **Infrastructure**: Flutter navigation system

## Risk Mitigation
- **Risk**: Navigation memory leaks affecting performance
- **Mitigation**: Proper disposal of controllers and listeners

- **Risk**: Settings not persisting correctly
- **Mitigation**: Comprehensive testing of SharedPreferences integration

## Definition of Done
- [ ] All implementation steps completed
- [ ] All menu screens functional and visually appealing
- [ ] Navigation system working smoothly
- [ ] Settings service saving and loading correctly
- [ ] Widget tests written and passing
- [ ] Responsive design validated on target devices
- [ ] Memory usage stable during navigation
- [ ] Integration with game controller working
- [ ] Code follows project standards
- [ ] User experience smooth and intuitive
