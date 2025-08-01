# Cloud Functions Development Guide

## Overview
This directory contains Firebase Cloud Functions for the Snakes Fight game, providing serverless backend functionality for room management and game logic validation.

## Project Structure
```
functions/
├── src/
│   ├── index.ts                 # Main exports
│   ├── room-management/         # Room creation and management
│   │   ├── create-room.ts       # Create game room
│   │   ├── join-room.ts         # Join existing room
│   │   └── cleanup-rooms.ts     # Scheduled room cleanup
│   ├── game-logic/              # Game state and validation
│   │   ├── validate-move.ts     # Move validation
│   │   └── game-state.ts        # Game state management
│   ├── utils/                   # Shared utilities
│   │   ├── database.ts          # Database helpers
│   │   ├── validation.ts        # Validation utilities
│   │   └── types.ts             # TypeScript type definitions
│   └── __tests__/               # Unit tests
├── package.json                 # Dependencies and scripts
├── tsconfig.json               # TypeScript configuration
├── jest.config.js              # Jest test configuration
└── .eslintrc.js                # ESLint configuration
```

## Available Functions

### Room Management
- `createRoom`: Creates a new game room with unique room code
- `joinRoom`: Allows players to join existing rooms
- `cleanupRooms`: Scheduled cleanup of stale rooms (runs every hour)

### Game Logic
- `validateMove`: Validates player moves in real-time
- `createGameState`: Initializes game state for a room
- `updateGameState`: Updates game state (placeholder for future implementation)

### Utility Functions
- `helloWorld`: Test function for verification
- `healthCheck`: Health status endpoint

## Development

### Prerequisites
- Node.js v18 LTS
- Firebase CLI installed globally
- Firebase project configured

### Setup
```bash
cd functions
npm install
```

### Development Scripts
```bash
# Build TypeScript
npm run build

# Watch mode for development
npm run build:watch

# Run linting
npm run lint

# Run tests
npm test

# Test with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

### Local Development
```bash
# Start Firebase emulators
npm run serve

# Run functions shell for testing
npm run shell
```

### Deployment
```bash
# Deploy to current Firebase project
npm run deploy

# Deploy to development environment
npm run deploy:dev

# Deploy to production environment
npm run deploy:prod

# View function logs
npm run logs
```

## Testing

### Unit Tests
Tests are located in `src/__tests__/` and can be run with:
```bash
npm test
```

### Integration Testing
For integration testing with Firebase emulators:
```bash
# Start emulators in one terminal
firebase emulators:start

# Run integration tests in another terminal
npm run test:integration
```

## Environment Configuration

### Development Environment
- Project ID: `snakes-fight-dev`
- Firestore: Development database
- Authentication: Test users allowed

### Production Environment
- Project ID: `snakes-fight-prod`
- Firestore: Production database
- Authentication: Full security rules

## Database Collections

### Rooms Collection (`rooms`)
```typescript
{
  code: string;           // 6-character room code
  hostId: string;         // Host user ID
  hostName: string;       // Host display name
  maxPlayers: number;     // Maximum players (default: 4)
  currentPlayers: number; // Current player count
  gameMode: string;       // Game mode (default: 'classic')
  isPrivate: boolean;     // Private room flag
  status: 'waiting' | 'starting' | 'in-progress' | 'completed';
  players: string[];      // Array of player user IDs
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### Players Collection (`players`)
```typescript
{
  userId: string;         // Firebase user ID
  roomCode: string;       // Associated room code
  playerName: string;     // Display name
  status: 'active' | 'disconnected' | 'left';
  joinedAt: string;       // ISO timestamp
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### Games Collection (`games`)
```typescript
{
  roomCode: string;       // Associated room
  gameId: string;         // Unique game identifier
  status: 'preparing' | 'active' | 'paused' | 'completed';
  players: PlayerGameData[];
  boardSize: { width: number; height: number };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

## Security

### Authentication
All callable functions require Firebase Authentication. Anonymous authentication is supported for quick game joining.

### Authorization
- Room hosts can start games
- Players can only join available rooms
- Move validation ensures fair gameplay

### Data Validation
All inputs are validated using utility functions:
- Room codes: 6-character alphanumeric
- Player names: 1-20 characters, safe characters only
- Game moves: Valid directions and positions

## Performance Considerations

### Cold Start Mitigation
- Functions are designed to be lightweight
- Minimal imports and dependencies
- Efficient database queries

### Scalability
- Firestore queries use proper indexing
- Functions are stateless and horizontally scalable
- Scheduled cleanup prevents data accumulation

## Monitoring

### Logging
All functions use structured logging:
```typescript
functions.logger.info('Operation completed', {
  userId: user.uid,
  roomCode: data.roomCode,
  duration: performance.now() - start
});
```

### Error Handling
Consistent error handling with:
- Proper HTTP error codes
- User-friendly error messages
- Detailed server-side logging

## Troubleshooting

### Common Issues
1. **Build Errors**: Check TypeScript configuration and imports
2. **Deployment Failures**: Verify Firebase project and permissions
3. **Function Timeouts**: Optimize database queries and reduce processing time
4. **Authentication Errors**: Check Firebase Auth configuration

### Debug Mode
Enable debug logging:
```bash
export DEBUG=firebase*
npm run serve
```

## Contributing

### Code Style
- Follow TypeScript best practices
- Use ESLint configuration provided
- Write tests for new functionality
- Update documentation for API changes

### Pull Request Process
1. Create feature branch
2. Write tests
3. Ensure all tests pass
4. Update documentation
5. Submit pull request with clear description
