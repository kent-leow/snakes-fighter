/// Utility functions for Snakes Fight game
class AppUtils {
  /// Prevents instantiation
  AppUtils._();
  
  /// Generates a random game room ID
  static String generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random % chars.length),
      ),
    );
  }
  
  /// Validates room ID format
  static bool isValidRoomId(String roomId) {
    final regex = RegExp(r'^[A-Z0-9]{6}$');
    return regex.hasMatch(roomId);
  }
  
  /// Formats player name for display
  static String formatPlayerName(String name) {
    if (name.trim().isEmpty) return 'Anonymous';
    return name.trim().substring(0, name.length > 20 ? 20 : name.length);
  }
}
