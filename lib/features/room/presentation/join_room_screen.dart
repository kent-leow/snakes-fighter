import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/room_providers.dart';

/// Screen for joining a room using a room code.
class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  static const routeName = '/join-room';

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RoomJoiningState>(roomJoiningProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      } else if (next.joinedRoom != null) {
        Navigator.of(
          context,
        ).pushReplacementNamed('/room', arguments: next.joinedRoom!.id);
      }
    });

    final roomJoiningState = ref.watch(roomJoiningProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Join Room'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.meeting_room, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              const Text(
                'Enter Room Code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask the host for the room code to join the game',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _roomCodeController,
                decoration: const InputDecoration(
                  labelText: 'Room Code',
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                validator: _validateRoomCode,
                onChanged: (value) {
                  // Auto-format to uppercase
                  final cursorPosition = _roomCodeController.selection.start;
                  _roomCodeController.value = _roomCodeController.value
                      .copyWith(
                        text: value.toUpperCase(),
                        selection: TextSelection.collapsed(
                          offset: cursorPosition,
                        ),
                      );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: roomJoiningState.isLoading ? null : _joinRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: roomJoiningState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Join Room', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: roomJoiningState.isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateRoomCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a room code';
    }

    if (value.length != 6) {
      return 'Room code must be 6 characters';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
      return 'Room code must contain only letters and numbers';
    }

    return null;
  }

  void _joinRoom() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final roomCode = _roomCodeController.text.trim().toUpperCase();
    ref.read(roomJoiningProvider.notifier).joinRoom(roomCode);
  }
}
