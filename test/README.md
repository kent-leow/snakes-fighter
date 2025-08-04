# Test Configuration for Snakes Fight

## Overview
This directory contains comprehensive test suites for the Snakes Fight multiplayer game application.

## Test Structure

### Unit Tests (`test/`)
- **Core Services**: Tests for authentication, database, cache, and other core services
- **Game Logic**: Tests for game engine, synchronization, and state management
- **Room Management**: Tests for room creation, joining, and player management
- **Models**: Tests for data models and their serialization

### Integration Tests (`integration_test/`)
- **Multiplayer Flow**: End-to-end testing of multiplayer game scenarios
- **Firebase Integration**: Testing of Firebase services integration
- **Performance**: Testing of app performance and resource usage
- **Cross-Platform**: Testing across different platforms

### Widget Tests (`test/`)
- **UI Components**: Testing of individual widgets and their behavior
- **Navigation**: Testing of app navigation and routing
- **User Interactions**: Testing of user input handling

## Running Tests

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Specific Test Files
```bash
flutter test test/features/room/services/room_service_comprehensive_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Configuration

### Test Coverage Requirements
- Unit Tests: >90% coverage for critical components
- Integration Tests: All major user flows covered
- Widget Tests: All UI components tested

### Critical Components for Testing
1. **RoomService**: Room creation, joining, leaving
2. **GameEngine**: Game logic and state management  
3. **AuthService**: Authentication flows
4. **DatabaseService**: Data persistence and synchronization
5. **GameSyncService**: Real-time multiplayer synchronization

### Performance Benchmarks
- App startup: <10 seconds (including Firebase initialization)
- Room creation: <3 seconds
- Game state synchronization: <100ms latency
- Memory usage: <200MB during gameplay

## Mock Services

### Firebase Mocking
- Use `fake_cloud_firestore` for Firestore operations
- Mock `firebase_auth` for authentication testing
- Mock network calls for offline testing

### Service Mocking
- Mock all external service dependencies
- Use dependency injection for testability
- Provide test-specific configurations

## Test Data

### Sample Data
- Room configurations with different player counts
- Game states at various progression points
- User profiles with different authentication states
- Network scenarios (connected, disconnected, slow)

### Test Environments
- Unit tests: Isolated environment with mocks
- Integration tests: Real Firebase services (test project)
- E2E tests: Complete application stack

## Continuous Integration

### Test Pipeline
1. Static analysis (lint, format)
2. Unit test execution with coverage
3. Integration test execution
4. Performance benchmark validation
5. Cross-platform compatibility tests

### Quality Gates
- All tests must pass
- Code coverage >90% for critical paths
- Performance benchmarks met
- No critical security issues

## Debugging Tests

### Common Issues
- Firebase initialization timeouts
- Mock service configuration errors
- Widget finder timeouts
- Platform-specific failures

### Debug Tools
- Flutter inspector for widget testing
- Firebase emulator for integration testing
- Performance profiler for benchmark validation

## Best Practices

### Test Organization
- Group related tests together
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Clean up resources in tearDown

### Mock Management
- Keep mocks simple and focused
- Verify interactions where important
- Reset mocks between tests
- Use real objects when mocking is complex

### Async Testing
- Use `pumpAndSettle()` for widget tests
- Handle async operations properly
- Use timeouts for long-running operations
- Test both success and failure scenarios
