import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/room_providers.dart';
import 'widgets/max_players_selector.dart';

/// Screen for creating a new game room.
class CreateRoomScreen extends ConsumerWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomCreationState = ref.watch(roomCreationProvider);

    // Navigate to room when created
    ref.listen<RoomCreationState>(roomCreationProvider, (previous, next) {
      if (next.createdRoom != null && previous?.createdRoom == null) {
        // Room created successfully - navigate to room screen
        // TODO: Navigate to room screen when implemented
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room ${next.createdRoom!.roomCode} created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Room'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Create a New Game Room',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Description
            const Text(
              'Set up your game room and invite friends to join!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: roomCreationState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Create Room',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            // Error display
            if (roomCreationState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  roomCreationState.error!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Room code display
            if (roomCreationState.createdRoom != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Room Created!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Room Code: ${roomCreationState.createdRoom!.roomCode}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share this code with your friends!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _createRoom(WidgetRef ref) {
    final maxPlayers = ref.read(maxPlayersProvider);
    ref.read(roomCreationProvider.notifier).createRoom(maxPlayers: maxPlayers);
  }
}
