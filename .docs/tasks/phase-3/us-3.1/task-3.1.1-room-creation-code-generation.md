# Task 3.1.1: Room Creation and Code Generation

## Overview
- User Story: us-3.1-room-management
- Task ID: task-3.1.1-room-creation-code-generation
- Priority: Critical
- Effort: 12 hours
- Dependencies: task-2.3.2-firebase-database-service, task-2.2.3-auth-state-management

## Description
Implement room creation functionality with unique room code generation, host assignment, and initial room state setup. Create user interface for room creation and ensure proper integration with authentication and database services.

## Technical Requirements
### Components
- Room Service: Business logic for room operations
- Code Generator: Unique room code generation
- Room Creation UI: User interface for creating rooms
- State Management: Room state providers

### Tech Stack
- flutter_riverpod: State management
- crypto: Random code generation
- Custom Services: Room management business logic
- Flutter Widgets: Room creation interface

## Implementation Steps
### Step 1: Implement Room Code Generation
- Action: Create unique room code generation system
- Deliverable: Reliable room code generator with collision detection
- Acceptance: Generated codes are unique and user-friendly
- Files: `lib/core/services/room_code_service.dart`

### Step 2: Create Room Service
- Action: Implement room creation business logic
- Deliverable: Complete room creation service
- Acceptance: Rooms created with proper host assignment
- Files: `lib/features/room/services/room_service.dart`

### Step 3: Build Room Creation UI
- Action: Create user interface for room creation
- Deliverable: Room creation screen with form validation
- Acceptance: Users can create rooms through intuitive UI
- Files: `lib/features/room/presentation/create_room_screen.dart`

### Step 4: Integrate State Management
- Action: Connect room creation to app state management
- Deliverable: Reactive room creation state
- Acceptance: UI updates based on room creation state
- Files: `lib/features/room/providers/room_providers.dart`

## Technical Specs
### Room Code Generator
```dart
class RoomCodeService {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _codeLength = 6;
  final Random _random = Random.secure();
  final DatabaseService _databaseService;
  
  RoomCodeService(this._databaseService);
  
  Future<String> generateUniqueRoomCode() async {
    int attempts = 0;
    const maxAttempts = 10;
    
    while (attempts < maxAttempts) {
      final code = _generateCode();
      
      // Check if code is already in use
      final existingRoom = await _databaseService.getRoomByCode(code);
      if (existingRoom == null) {
        return code;
      }
      
      attempts++;
    }
    
    throw RoomException('Failed to generate unique room code after $maxAttempts attempts');
  }
  
  String _generateCode() {
    return List.generate(_codeLength, (index) {
      return _chars[_random.nextInt(_chars.length)];
    }).join();
  }
}
```

### Room Service
```dart
class RoomService {
  final DatabaseService _databaseService;
  final AuthService _authService;
  final RoomCodeService _roomCodeService;
  
  RoomService(
    this._databaseService,
    this._authService,
    this._roomCodeService,
  );
  
  Future<Room> createRoom({
    int maxPlayers = 4,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw RoomException('User must be authenticated to create room');
    }
    
    final roomCode = await _roomCodeService.generateUniqueRoomCode();
    final roomId = _generateRoomId();
    
    final host = Player(
      uid: user.uid,
      displayName: user.displayName ?? 'Anonymous',
      color: PlayerColor.red,
      joinedAt: DateTime.now(),
      isReady: false,
    );
    
    final room = Room(
      id: roomId,
      roomCode: roomCode,
      hostId: user.uid,
      status: RoomStatus.waiting,
      createdAt: DateTime.now(),
      maxPlayers: maxPlayers,
      players: {user.uid: host},
    );
    
    return await _databaseService.createRoom(room);
  }
  
  String _generateRoomId() {
    return 'room_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}
```

### Room Creation State Provider
```dart
final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService(
    ref.read(databaseServiceProvider),
    ref.read(authServiceProvider),
    ref.read(roomCodeServiceProvider),
  );
});

final roomCreationProvider = StateNotifierProvider<RoomCreationNotifier, RoomCreationState>((ref) {
  return RoomCreationNotifier(ref.read(roomServiceProvider));
});

class RoomCreationState {
  final bool isLoading;
  final Room? createdRoom;
  final String? error;
  
  const RoomCreationState({
    this.isLoading = false,
    this.createdRoom,
    this.error,
  });
  
  RoomCreationState copyWith({
    bool? isLoading,
    Room? createdRoom,
    String? error,
  }) {
    return RoomCreationState(
      isLoading: isLoading ?? this.isLoading,
      createdRoom: createdRoom ?? this.createdRoom,
      error: error ?? this.error,
    );
  }
}

class RoomCreationNotifier extends StateNotifier<RoomCreationState> {
  final RoomService _roomService;
  
  RoomCreationNotifier(this._roomService) : super(const RoomCreationState());
  
  Future<void> createRoom({int maxPlayers = 4}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final room = await _roomService.createRoom(maxPlayers: maxPlayers);
      state = state.copyWith(
        isLoading: false,
        createdRoom: room,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

### Room Creation UI
```dart
class CreateRoomScreen extends ConsumerWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomCreationState = ref.watch(roomCreationProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create a new game room',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Max players selection
            const MaxPlayersSelector(),
            
            const SizedBox(height: 32),
            
            // Create room button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: roomCreationState.isLoading 
                    ? null 
                    : () => _createRoom(ref),
                child: roomCreationState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Room'),
              ),
            ),
            
            // Error display
            if (roomCreationState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  roomCreationState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _createRoom(WidgetRef ref) {
    ref.read(roomCreationProvider.notifier).createRoom();
  }
}
```

## Testing
- [ ] Unit tests for room code generation uniqueness
- [ ] Integration tests for room creation flow
- [ ] Widget tests for room creation UI components

## Acceptance Criteria
- [ ] Room code generation produces unique codes
- [ ] Room creation service creates properly structured rooms
- [ ] Room creation UI provides intuitive user experience
- [ ] Authentication integration prevents unauthorized room creation
- [ ] Error handling for room creation failures
- [ ] State management updates UI reactively

## Dependencies
- Before: Database service and authentication system complete
- After: Room joining functionality can be implemented
- External: Firebase Realtime Database for room storage

## Risks
- Risk: Room code collision in high-usage scenarios
- Mitigation: Robust collision detection and retry mechanism

## Definition of Done
- [ ] Room code generation implemented and tested
- [ ] Room creation service functional
- [ ] Room creation UI complete and tested
- [ ] State management integrated
- [ ] Error handling comprehensive
- [ ] Authentication integration working
