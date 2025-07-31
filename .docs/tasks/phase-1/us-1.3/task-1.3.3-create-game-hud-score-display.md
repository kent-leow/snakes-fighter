# Task 1.3.3: Create Game HUD and Score Display

## Task Overview
- **User Story**: us-1.3-basic-game-ui
- **Task ID**: task-1.3.3-create-game-hud-score-display
- **Priority**: High
- **Estimated Effort**: 8 hours
- **Dependencies**: task-1.3.1-create-game-canvas-rendering-system, task-1.2.4-create-complete-game-loop

## Description
Create a heads-up display (HUD) that shows essential game information including current score/length, game status, and provides basic game controls. The HUD should be unobtrusive while providing necessary information to the player.

## Technical Requirements
### Architecture Components
- **Frontend**: HUD widgets, score management, game status display
- **Backend**: None (UI display)
- **Database**: None (UI state)
- **Integration**: Integration with game controller for real-time data

### Technology Stack
- **Language/Framework**: Flutter widgets, Material Design
- **Dependencies**: Flutter material design components
- **Tools**: Flutter UI framework

## Implementation Steps

### Step 1: Create Score Management System
- **Action**: Implement score tracking and calculation based on snake length and food consumed
- **Deliverable**: Score management system that updates in real-time
- **Acceptance**: Accurate score calculation and tracking throughout game
- **Files**: lib/features/game/models/score_manager.dart

### Step 2: Design HUD Layout
- **Action**: Create responsive HUD layout that doesn't interfere with gameplay
- **Deliverable**: HUD widget with optimal positioning and sizing
- **Acceptance**: HUD is visible but not distracting from gameplay
- **Files**: lib/features/game/widgets/game_hud.dart

### Step 3: Implement Real-time Score Display
- **Action**: Create score display widget that updates automatically
- **Deliverable**: Live score display connected to game state
- **Acceptance**: Score updates immediately when game state changes
- **Files**: lib/features/game/widgets/score_display_widget.dart

### Step 4: Add Game Status Indicators
- **Action**: Display current game state (playing, paused, game over)
- **Deliverable**: Status indicators and messages for different game states
- **Acceptance**: Clear visual indication of current game status
- **Files**: lib/features/game/widgets/game_status_widget.dart

### Step 5: Create Basic Game Controls UI
- **Action**: Add pause/resume button and restart game functionality
- **Deliverable**: Basic game control buttons integrated with HUD
- **Acceptance**: Game controls are accessible and functional
- **Files**: lib/features/game/widgets/game_controls_widget.dart

## Technical Specifications
### Score Manager
```dart
class ScoreManager {
  int _currentScore = 0;
  int _highScore = 0;
  
  int get currentScore => _currentScore;
  int get highScore => _highScore;
  
  void addPoints(int points);
  void resetScore();
  void updateHighScore();
  Stream<int> get scoreStream;
}
```

### Game HUD Widget
```dart
class GameHUD extends StatelessWidget {
  final ScoreManager scoreManager;
  final GameStateManager stateManager;
  final VoidCallback onPause;
  final VoidCallback onRestart;
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: _buildHUDContent(),
    );
  }
}
```

### Score Display Widget
```dart
class ScoreDisplayWidget extends StatelessWidget {
  final Stream<int> scoreStream;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: scoreStream,
      builder: (context, snapshot) {
        return Text(
          'Score: ${snapshot.data ?? 0}',
          style: Theme.of(context).textTheme.headlineSmall,
        );
      },
    );
  }
}
```

### Game Status Widget
```dart
class GameStatusWidget extends StatelessWidget {
  final GameState gameState;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _buildStatusContent(),
    );
  }
  
  Widget _buildStatusContent() {
    switch (gameState) {
      case GameState.paused:
        return Text('PAUSED');
      case GameState.gameOver:
        return Text('GAME OVER');
      default:
        return SizedBox.shrink();
    }
  }
}
```

## Testing Requirements
- [ ] Widget tests for HUD components
- [ ] Unit tests for score calculation logic
- [ ] Integration tests with game controller
- [ ] Visual tests for different screen sizes
- [ ] Performance tests for HUD rendering

## Acceptance Criteria
- [ ] HUD displays current score/length accurately
- [ ] Game status is clearly indicated
- [ ] HUD is responsive across different screen sizes
- [ ] Score updates in real-time during gameplay
- [ ] Game controls (pause/restart) are functional
- [ ] HUD doesn't interfere with gameplay visibility
- [ ] Visual design is clean and professional
- [ ] All implementation steps completed

## Dependencies
### Task Dependencies
- **Before**: task-1.3.1-create-game-canvas-rendering-system, task-1.2.4-create-complete-game-loop
- **After**: Integration testing, UI polish in later phases

### External Dependencies
- **Services**: Flutter material design components
- **Infrastructure**: Game controller and state management systems

## Risk Mitigation
- **Risk**: HUD elements obscuring gameplay
- **Mitigation**: Careful positioning and sizing, user testing for optimal placement

- **Risk**: Performance impact from frequent UI updates
- **Mitigation**: Efficient state management and widget rebuilding strategies

## Definition of Done
- [ ] All implementation steps completed
- [ ] HUD displays all required game information
- [ ] Score tracking and display working correctly
- [ ] Game status indicators functional
- [ ] Basic game controls integrated and working
- [ ] Responsive design across target platforms
- [ ] Widget tests written and passing
- [ ] Integration with game controller validated
- [ ] Visual design meets quality standards
- [ ] Performance requirements met
