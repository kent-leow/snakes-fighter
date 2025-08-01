import 'package:firebase_auth/firebase_auth.dart';

/// Authentication status enumeration
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Enhanced authentication state model
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isAnonymous = false,
  });

  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isAnonymous;

  /// Check if user is authenticated
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Check if authentication is in progress
  bool get isLoading => status == AuthStatus.loading;

  /// Check if there's an error
  bool get hasError => status == AuthStatus.error && error != null;

  /// Get user display name
  String get displayName {
    if (user == null) return 'Guest';

    if (user!.isAnonymous) {
      // Generate a friendly name for anonymous users
      final uid = user!.uid;
      final shortId = uid.length > 6 ? uid.substring(0, 6) : uid;
      return 'Player $shortId';
    }

    return user!.displayName ?? user!.email ?? 'Unknown User';
  }

  /// Create a copy with updated fields
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isAnonymous,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// Create loading state
  AuthState loading() => copyWith(status: AuthStatus.loading, clearError: true);

  /// Create error state
  AuthState withError(String error) =>
      copyWith(status: AuthStatus.error, error: error);

  /// Create authenticated state
  AuthState withUser(User? user) => copyWith(
    status: user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated,
    user: user,
    isAnonymous: user?.isAnonymous ?? false,
    clearError: true,
  );

  /// Create initial state
  AuthState initial() => copyWith(status: AuthStatus.initial, clearError: true);

  /// Create unauthenticated state
  AuthState unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.uid}, error: $error, isAnonymous: $isAnonymous)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.status == status &&
        other.user?.uid == user?.uid &&
        other.error == error &&
        other.isAnonymous == isAnonymous;
  }

  @override
  int get hashCode => Object.hash(status, user?.uid, error, isAnonymous);
}

/// User data model for persistence
class UserData {
  const UserData({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isAnonymous,
    required this.createdAt,
    this.lastSignInAt,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final String? photoUrl;

  /// Create UserData from Firebase User
  factory UserData.fromFirebaseUser(User user) {
    return UserData(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: user.metadata.lastSignInTime,
      photoUrl: user.photoURL,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  /// Create from JSON storage
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserData(uid: $uid, email: $email, displayName: $displayName, isAnonymous: $isAnonymous)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.isAnonymous == isAnonymous &&
        other.createdAt == createdAt &&
        other.lastSignInAt == lastSignInAt &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(
    uid,
    email,
    displayName,
    isAnonymous,
    createdAt,
    lastSignInAt,
    photoUrl,
  );
}
