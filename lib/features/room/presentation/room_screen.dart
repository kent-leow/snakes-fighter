import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../providers/room_providers.dart';

/// Screen displaying the current room and player management.
class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key, required this.roomId});

  final String roomId;
  static const routeName = '/room';

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  @override
  void initState() {
    super.initState();
    // Set the room when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentRoomProvider.notifier).setRoom(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoomState = ref.watch(currentRoomProvider);

    if (currentRoomState.isLoading && currentRoomState.room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentRoomState.error != null && currentRoomState.room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Room')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${currentRoomState.error}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final room = currentRoomState.room;
    if (room == null) {
      return const Scaffold(body: Center(child: Text('Room not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${room.roomCode}'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _copyRoomCode(context, room.roomCode),
            icon: const Icon(Icons.copy),
            tooltip: 'Copy room code',
          ),
          if (currentRoomState.isHost)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value, room),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'start_game',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 8),
                      Text('Start Game'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Room info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Room Code',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            room.roomCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Players',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${room.players.length}/${room.maxPlayers}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(room.status),
                        color: _getStatusColor(room.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(room.status),
                        style: TextStyle(
                          color: _getStatusColor(room.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Players list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: room.players.length,
              itemBuilder: (context, index) {
                final playerId = room.players.keys.elementAt(index);
                final player = room.players[playerId]!;
                return _PlayerTile(
                  player: player,
                  isHost: room.hostId == playerId,
                  isCurrentUser:
                      playerId == room.hostId, // TODO: Get current user ID
                  canKick: currentRoomState.isHost && playerId != room.hostId,
                  onKick: currentRoomState.isHost
                      ? () => ref
                            .read(currentRoomProvider.notifier)
                            .kickPlayer(playerId)
                      : null,
                );
              },
            ),
          ),
          // Bottom actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!currentRoomState.isHost)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _toggleReady(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _getCurrentPlayerReady(room) ? 'Not Ready' : 'Ready',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _leaveRoom(context),
                    child: const Text('Leave Room'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyRoomCode(BuildContext context, String roomCode) {
    Clipboard.setData(ClipboardData(text: roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, Room room) {
    switch (action) {
      case 'start_game':
        if (room.canStartGame) {
          _startGame(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All players must be ready and connected to start'),
            ),
          );
        }
        break;
    }
  }

  void _startGame(BuildContext context) {
    // TODO: Implement game start logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting game... (Not implemented yet)')),
    );
  }

  void _toggleReady(BuildContext context) {
    final room = ref.read(currentRoomProvider).room;
    if (room == null) return;

    final currentReady = _getCurrentPlayerReady(room);
    ref.read(currentRoomProvider.notifier).updatePlayerReady(!currentReady);
  }

  bool _getCurrentPlayerReady(Room room) {
    // TODO: Get current user ID from auth service
    // For now, assume first non-host player
    final nonHostPlayers = room.players.entries
        .where((entry) => entry.key != room.hostId)
        .toList();

    if (nonHostPlayers.isNotEmpty) {
      return nonHostPlayers.first.value.isReady;
    }

    return false;
  }

  void _leaveRoom(BuildContext context) {
    ref.read(currentRoomProvider.notifier).leaveRoom();
    Navigator.of(context).pop();
  }

  IconData _getStatusIcon(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return Icons.hourglass_empty;
      case RoomStatus.active:
        return Icons.play_circle;
      case RoomStatus.ended:
        return Icons.flag;
    }
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return Colors.orange;
      case RoomStatus.active:
        return Colors.green;
      case RoomStatus.ended:
        return Colors.grey;
    }
  }

  String _getStatusText(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return 'Waiting for players';
      case RoomStatus.active:
        return 'Game in progress';
      case RoomStatus.ended:
        return 'Game ended';
    }
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.isHost,
    required this.isCurrentUser,
    required this.canKick,
    this.onKick,
  });

  final Player player;
  final bool isHost;
  final bool isCurrentUser;
  final bool canKick;
  final VoidCallback? onKick;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPlayerColor(player.color),
          child: Text(
            player.displayName.isNotEmpty
                ? player.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                player.displayName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (isHost)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'HOST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(
              player.isConnected ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: player.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(player.isConnected ? 'Connected' : 'Disconnected'),
            const SizedBox(width: 16),
            Icon(
              player.isReady
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 16,
              color: player.isReady ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(player.isReady ? 'Ready' : 'Not Ready'),
          ],
        ),
        trailing: canKick
            ? IconButton(
                onPressed: onKick,
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
                tooltip: 'Kick player',
              )
            : null,
      ),
    );
  }

  Color _getPlayerColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return Colors.red;
      case PlayerColor.blue:
        return Colors.blue;
      case PlayerColor.green:
        return Colors.green;
      case PlayerColor.yellow:
        return Colors.yellow[700]!;
    }
  }
}
