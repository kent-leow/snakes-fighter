import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Exception thrown when authentication operations fail
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Service for handling Firebase authentication operations
class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;

  // Keys for secure storage
  static const String _userIdKey = 'user_id';
  static const String _isAnonymousKey = 'is_anonymous';

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();

      // Store user information securely
      if (result.user != null) {
        await _storeUserSession(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Anonymous sign-in failed: ${e.message}');
    } catch (e) {
      throw AuthException('Anonymous sign-in failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Sign out from Google first if signed in with Google
      if (_auth.currentUser?.providerData.any(
            (provider) => provider.providerId == 'google.com',
          ) ==
          true) {
        await _googleSignIn.signOut();
      }

      await _auth.signOut();
      await _clearUserSession();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign out failed: ${e.message}');
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Return null if the user canceled the sign-in
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final result = await _auth.signInWithCredential(credential);

      // Store user information securely
      if (result.user != null) {
        await _storeUserSession(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Google sign-in failed: ${e.message}');
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  /// Link anonymous account with Google
  Future<UserCredential?> linkAnonymousWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw const AuthException('No anonymous user to link');
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Return null if the user canceled the sign-in
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the anonymous account with Google credentials
      final result = await user.linkWithCredential(credential);

      // Update stored user session
      if (result.user != null) {
        await _storeUserSession(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Account linking failed: ${e.message}');
    } catch (e) {
      throw AuthException('Account linking failed: $e');
    }
  }

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Check if current user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  /// Get user display name or generate one for anonymous users
  String get userDisplayName {
    final user = _auth.currentUser;
    if (user == null) return 'Guest';

    if (user.isAnonymous) {
      // Generate a friendly name for anonymous users
      final uid = user.uid;
      final shortId = uid.length > 6 ? uid.substring(0, 6) : uid;
      return 'Player $shortId';
    }

    return user.displayName ?? user.email ?? 'Unknown User';
  }

  /// Store user session information securely
  Future<void> _storeUserSession(User user) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: user.uid);
      await _secureStorage.write(
        key: _isAnonymousKey,
        value: user.isAnonymous.toString(),
      );
    } catch (e) {
      // Log error but don't throw - session storage is not critical
      debugPrint('Warning: Failed to store user session: $e');
    }
  }

  /// Clear stored user session information
  Future<void> _clearUserSession() async {
    try {
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _isAnonymousKey);
    } catch (e) {
      // Log error but don't throw - session clearing is not critical
      debugPrint('Warning: Failed to clear user session: $e');
    }
  }

  /// Get stored user ID
  Future<String?> getStoredUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      debugPrint('Warning: Failed to read stored user ID: $e');
      return null;
    }
  }

  /// Get stored anonymous status
  Future<bool> getStoredAnonymousStatus() async {
    try {
      final value = await _secureStorage.read(key: _isAnonymousKey);
      return value == 'true';
    } catch (e) {
      debugPrint('Warning: Failed to read stored anonymous status: $e');
      return false;
    }
  }

  /// Delete anonymous user account (irreversible)
  Future<void> deleteAnonymousUser() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw const AuthException('No anonymous user to delete');
    }

    try {
      await user.delete();
      await _clearUserSession();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Failed to delete anonymous user: ${e.message}');
    } catch (e) {
      throw AuthException('Failed to delete anonymous user: $e');
    }
  }
}
