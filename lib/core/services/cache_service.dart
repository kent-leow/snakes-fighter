import 'dart:async';

/// Cache entry with expiration time.
class CacheEntry<T> {
  /// Creates a cache entry.
  const CacheEntry({required this.value, required this.expiry});

  /// The cached value.
  final T value;

  /// The expiry time for this entry.
  final DateTime expiry;

  /// Whether this entry has expired.
  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Service for caching frequently accessed data.
class CacheService {
  /// Creates a new cache service.
  CacheService({Duration defaultTtl = const Duration(minutes: 5)})
    : _defaultTtl = defaultTtl;

  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultTtl;

  /// Gets a cached value by key.
  ///
  /// Returns null if the key doesn't exist or has expired.
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }

  /// Sets a cached value with optional TTL.
  ///
  /// If [ttl] is not provided, uses the default TTL.
  void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = CacheEntry<T>(
      value: value,
      expiry: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }

  /// Invalidates a specific cache key.
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Clears all cached data.
  void clear() {
    _cache.clear();
  }

  /// Gets or sets a cached value using a factory function.
  ///
  /// If the key exists and is not expired, returns the cached value.
  /// Otherwise, calls the factory function and caches the result.
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() factory, {
    Duration? ttl,
  }) async {
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    final value = await factory();
    set(key, value, ttl: ttl);
    return value;
  }

  /// Gets the number of cached entries.
  int get size => _cache.length;

  /// Gets all cache keys.
  Iterable<String> get keys => _cache.keys;

  /// Removes expired entries from the cache.
  void cleanup() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiry));
  }

  /// Starts automatic cleanup of expired entries.
  ///
  /// Returns a timer that can be cancelled to stop cleanup.
  Timer startPeriodicCleanup({
    Duration interval = const Duration(minutes: 10),
  }) {
    return Timer.periodic(interval, (_) => cleanup());
  }
}
