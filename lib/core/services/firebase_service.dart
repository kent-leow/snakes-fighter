import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Service class for Firebase interactions
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseDatabase get database => _database;
  FirebaseAnalytics get analytics => _analytics;

  // Authentication methods
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Database references
  DatabaseReference get gamesRef => _database.ref('games');
  DatabaseReference get playersRef => _database.ref('players');
  DatabaseReference get lobbiesRef => _database.ref('lobbies');

  DatabaseReference gameRef(String gameId) => gamesRef.child(gameId);
  DatabaseReference playerRef(String uid) => playersRef.child(uid);
  DatabaseReference lobbyRef(String lobbyId) => lobbiesRef.child(lobbyId);

  // Analytics methods
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      // Analytics errors should not crash the app
      // ignore: avoid_print
      print('Analytics error: $e');
    }
  }

  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      // ignore: avoid_print
      print('Analytics error setting user ID: $e');
    }
  }

  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      // ignore: avoid_print
      print('Analytics error setting user property: $e');
    }
  }
}
