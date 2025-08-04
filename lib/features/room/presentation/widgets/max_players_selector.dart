import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for selected max players count.
final maxPlayersProvider = StateProvider<int>((ref) => 4);

/// Widget for selecting maximum number of players in a room.
class MaxPlayersSelector extends ConsumerWidget {
  const MaxPlayersSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxPlayers = ref.watch(maxPlayersProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Maximum Players',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 2; i <= 8; i++)
                _PlayerCountOption(
                  count: i,
                  isSelected: maxPlayers == i,
                  onTap: () => ref.read(maxPlayersProvider.notifier).state = i,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual player count option button.
class _PlayerCountOption extends StatelessWidget {
  const _PlayerCountOption({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade100,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
