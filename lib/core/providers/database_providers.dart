import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/database_service.dart';

/// Provider for the database service.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return FirebaseDatabaseService();
});
