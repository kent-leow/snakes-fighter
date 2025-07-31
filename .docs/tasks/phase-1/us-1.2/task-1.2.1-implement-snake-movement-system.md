# Task 1.2.1: Implement Snake Movement System

## Task Overview
- **User Story**: us-1.2-core-game-engine
- *### Task Dependencies
- **Before**: task-1.2.0-implement-core-grid-system
- **After**: task-1.2.2-implement-food-system, task-1.2.3-implement-collision-detection-system

### External Dependencies
- **Services**: Grid system from task-1.2.0
- **Infrastructure**: Development environment setupD**: task-1.2.1-implement-snake-movement-system
- **Priority**: Critical
- **Estimated Effort**: 16 hours
- **Dependencies**: task-1.2.0-implement-core-grid-system

## Description
Implement the core snake movement mechanics including 4-directional movement, input handling, and movement validation. The snake should move continuously in a grid-based system with proper direction change handling.

## Technical Requirements
### Architecture Components
- **Frontend**: Snake movement logic, input handlers, game loop
- **Backend**: None (local game logic)
- **Database**: None (local state)
- **Integration**: Input system integration

### Technology Stack
- **Language/Framework**: Flutter/Dart, CustomPainter for rendering
- **Dependencies**: None (core Flutter functionality)
- **Tools**: Flutter animation/game loop APIs

## Implementation Steps

### Step 1: Create Snake Data Model
- **Action**: Define Snake class with position, direction, and movement properties
- **Deliverable**: Snake model with position tracking
- **Acceptance**: Snake can store position and direction state
- **Files**: lib/features/game/models/snake.dart

### Step 2: Implement Grid System
- **Action**: Create grid-based coordinate system for game world
- **Deliverable**: Grid utilities and coordinate management
- **Acceptance**: Consistent grid positioning and coordinate conversion
- **Files**: lib/core/utils/grid_system.dart

### Step 3: Create Movement Logic
- **Action**: Implement snake movement with direction validation
- **Deliverable**: Movement system that prevents backwards movement
- **Acceptance**: Snake moves correctly and rejects invalid directions
- **Files**: lib/features/game/logic/movement_system.dart

### Step 4: Setup Game Loop
- **Action**: Create game loop with consistent timing for movement updates
- **Deliverable**: Game loop with configurable tick rate
- **Acceptance**: Snake moves at consistent speed (e.g., 10 moves per second)
- **Files**: lib/features/game/controllers/game_controller.dart

### Step 5: Implement Input Handling
- **Action**: Create input system for keyboard and touch controls
- **Deliverable**: Input handlers for direction changes
- **Acceptance**: Responsive input handling with immediate direction changes
- **Files**: lib/features/game/controllers/input_controller.dart

## Technical Specifications
### Snake Model
```dart
class Snake {
  List<Position> body;
  Direction currentDirection;
  Direction nextDirection;
  
  void move();
  bool canChangeDirection(Direction newDirection);
  void changeDirection(Direction direction);
}
```

### Grid System
```dart
class GridSystem {
  static const int gridSize = 20;
  static const double cellSize = 20.0;
  
  static Position screenToGrid(Offset screenPosition);
  static Offset gridToScreen(Position gridPosition);
  static bool isValidPosition(Position position);
}
```

### Movement System
```dart
class MovementSystem {
  static void updateSnakePosition(Snake snake);
  static bool isValidDirection(Direction current, Direction next);
  static Direction getOppositeDirection(Direction direction);
}
```

## Testing Requirements
- [ ] Unit tests for Snake model methods
- [ ] Unit tests for movement validation logic
- [ ] Unit tests for grid coordinate conversion
- [ ] Integration tests for input handling
- [ ] Performance tests for game loop timing

## Acceptance Criteria
- [ ] Snake moves in 4 directions (up, down, left, right)
- [ ] Direction changes are processed immediately
- [ ] Backwards movement is prevented
- [ ] Game loop maintains consistent timing
- [ ] Input response time <50ms
- [ ] All implementation steps completed
- [ ] Tests written and passing
- [ ] Code reviewed and approved

## Dependencies
### Task Dependencies
- **Before**: task-1.1.1-initialize-flutter-project, task-1.1.2-configure-development-environment
- **After**: task-1.2.2-implement-food-system, task-1.2.3-implement-collision-detection

### External Dependencies
- **Services**: None (core Flutter functionality)
- **Infrastructure**: Development environment setup

## Risk Mitigation
- **Risk**: Game loop performance issues on mobile
- **Mitigation**: Implement efficient movement algorithms and test on target devices

- **Risk**: Input lag affecting gameplay
- **Mitigation**: Optimize input handling and separate input from rendering loops

## Definition of Done
- [ ] All implementation steps completed
- [ ] Snake movement system functional
- [ ] Input handling responsive and accurate
- [ ] Game loop timing consistent
- [ ] Unit tests written and passing
- [ ] Performance requirements met (60fps, <50ms input response)
- [ ] Code follows project standards
- [ ] Integration validated with game rendering
