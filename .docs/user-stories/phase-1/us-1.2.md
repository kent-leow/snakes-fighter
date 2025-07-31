# User Story 1.2: Implement Core Game Engine

## Story
**As a** player  
**I want** to control a snake that moves, grows when eating food, and dies when hitting obstacles  
**So that** I can enjoy the basic snake game mechanics

## Business Context
- **Module**: Core Game Engine
- **Phase**: Foundation & Core Game Engine
- **Priority**: Critical
- **Business Value**: Core gameplay experience that forms the foundation for multiplayer features
- **Related Requirements**: REQ-GM-001, REQ-GM-002, REQ-GM-003

## Acceptance Criteria
### Functional Requirements
- [ ] **Given** the game is running **When** I press arrow keys or swipe **Then** the snake should move in the corresponding direction
- [ ] **Given** the snake is moving **When** I try to move backwards **Then** the movement should be ignored
- [ ] **Given** the snake encounters food **When** the snake head touches food **Then** the snake should grow by one segment
- [ ] **Given** food is consumed **When** the snake eats it **Then** new food should spawn at a random location
- [ ] **Given** the snake is moving **When** it hits a wall **Then** the snake should die and game should end
- [ ] **Given** the snake is moving **When** it hits its own body **Then** the snake should die and game should end
- [ ] **Given** the game is active **When** collision occurs **Then** death animation should play and game state should update

### Non-Functional Requirements
- [ ] Performance: Game runs at consistent 60fps
- [ ] Performance: Response time to input <50ms
- [ ] Usability: Smooth snake movement animation
- [ ] Usability: Clear visual feedback for collisions

## Business Rules
- Snake moves in 4 directions only (up, down, left, right)
- Snake cannot reverse direction instantly
- Snake grows by exactly one segment when eating food
- Only one food item exists at a time
- Game ends immediately upon any collision

## Dependencies
### Technical Dependencies
- Flutter Framework: For cross-platform rendering
- Game Loop: For consistent frame updates
- Input System: For handling user controls

### Story Dependencies
- US 1.1: Project foundation must be established

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests written and passing
- [ ] Snake movement system functional
- [ ] Food system working correctly
- [ ] Collision detection implemented
- [ ] Single-player game loop complete
- [ ] Performance requirements met
- [ ] Manual testing on target platforms completed

## Notes
### Technical Considerations
- Use efficient collision detection algorithms
- Implement smooth interpolation for movement
- Consider using a grid-based coordinate system
- Optimize rendering for mobile devices

### Business Assumptions
- Single-player gameplay serves as foundation for multiplayer
- Basic graphics are sufficient for MVP
- Touch controls work well on mobile devices

## Estimated Effort
- **Story Points**: 8
- **Estimated Hours**: 40-80 hours
- **Complexity**: Medium
