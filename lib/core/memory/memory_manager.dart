import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../core/models/position.dart';

/// Efficient memory management system with object pooling for game objects.
///
/// Provides object pools for frequently allocated objects to reduce garbage
/// collection pressure and improve performance.
class MemoryManager {
  static MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final Map<Type, ObjectPool> _objectPools = {};
  Timer? _gcTimer;
  int _allocationCount = 0;
  int _poolHitCount = 0;
  bool _isInitialized = false;

  /// Reset singleton instance for testing
  static void reset() {
    _instance.dispose();
    _instance = MemoryManager._internal();
  }

  /// Initializes the memory manager with object pools.
  void initialize() {
    if (_isInitialized) return;

    // Initialize object pools for frequently used objects
    _objectPools[Position] = ObjectPool<Position>(
      createFn: () => const Position(0, 0),
      resetFn: (pos) {
        // Position is immutable, so we don't need to reset it
      },
      maxSize: 1000,
    );

    // Start periodic garbage collection optimization
    _startGCOptimization();

    _isInitialized = true;
    debugPrint('MemoryManager initialized with ${_objectPools.length} pools');
  }

  /// Gets an object from the appropriate pool or creates a new one.
  T getObject<T>() {
    final pool = _objectPools[T] as ObjectPool<T>?;
    if (pool != null) {
      final obj = pool.get();
      if (obj != null) {
        _poolHitCount++;
        return obj;
      }
    }

    _allocationCount++;
    return _createObject<T>();
  }

  /// Returns an object to the appropriate pool for reuse.
  void returnObject<T>(T object) {
    final pool = _objectPools[T] as ObjectPool<T>?;
    pool?.returnToPool(object);
  }

  /// Gets memory statistics for monitoring.
  Map<String, dynamic> getMemoryStats() {
    final totalPooledObjects = _objectPools.values
        .map((pool) => pool.size)
        .fold(0, (sum, size) => sum + size);

    final hitRate = _poolHitCount + _allocationCount > 0
        ? _poolHitCount / (_poolHitCount + _allocationCount)
        : 0.0;

    return {
      'allocation_count': _allocationCount,
      'pool_hit_count': _poolHitCount,
      'hit_rate': hitRate,
      'total_pooled_objects': totalPooledObjects,
      'pool_sizes': _objectPools.map(
        (type, pool) => MapEntry(type.toString(), pool.size),
      ),
      'pool_capacities': _objectPools.map(
        (type, pool) => MapEntry(type.toString(), pool.maxSize),
      ),
    };
  }

  /// Triggers memory optimization.
  void optimizeMemory() {
    _optimizeMemory();
  }

  /// Disposes of the memory manager and cleans up resources.
  void dispose() {
    _gcTimer?.cancel();
    _gcTimer = null;

    for (final pool in _objectPools.values) {
      pool.clear();
    }
    _objectPools.clear();

    _isInitialized = false;
    debugPrint('MemoryManager disposed');
  }

  // Private methods

  T _createObject<T>() {
    // Factory method for creating objects
    switch (T) {
      case const (Position):
        return const Position(0, 0) as T;
      default:
        throw UnsupportedError('Object type $T not supported by pool');
    }
  }

  void _startGCOptimization() {
    _gcTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _optimizeMemory();
    });
  }

  void _optimizeMemory() {
    // Clear excessive pool objects to prevent memory bloat
    for (final pool in _objectPools.values) {
      pool.trim();
    }

    // Log memory statistics
    final stats = getMemoryStats();
    final hitRate = stats['hit_rate'] as double;
    debugPrint('Memory pool hit rate: ${(hitRate * 100).toStringAsFixed(1)}%');

    if (kDebugMode) {
      debugPrint('Memory stats: $stats');
    }
  }
}

/// Generic object pool for efficient object reuse.
class ObjectPool<T> {
  final T Function() createFn;
  final void Function(T) resetFn;
  final int maxSize;
  final Queue<T> _objects = Queue<T>();

  ObjectPool({
    required this.createFn,
    required this.resetFn,
    required this.maxSize,
  });

  /// Gets an object from the pool or returns null if empty.
  T? get() {
    if (_objects.isNotEmpty) {
      final obj = _objects.removeFirst();
      resetFn(obj);
      return obj;
    }
    return null;
  }

  /// Returns an object to the pool for reuse.
  void returnToPool(T object) {
    if (_objects.length < maxSize) {
      _objects.add(object);
    }
  }

  /// Trims the pool to half capacity to free memory.
  void trim() {
    final targetSize = maxSize ~/ 2;
    while (_objects.length > targetSize) {
      _objects.removeFirst();
    }
  }

  /// Clears all objects from the pool.
  void clear() {
    _objects.clear();
  }

  /// Gets the current size of the pool.
  int get size => _objects.length;
}

/// Extension methods for memory-efficient operations.
extension MemoryOptimizedList<T> on List<T> {
  /// Adds an element using memory manager if available.
  void addWithMemoryManagement(T element) {
    add(element);
  }

  /// Removes an element and returns it to memory pool if possible.
  T removeWithMemoryManagement(int index) {
    final element = removeAt(index);

    // Try to return to memory pool
    try {
      MemoryManager().returnObject(element);
    } catch (e) {
      // Object type not supported by pool, ignore
    }

    return element;
  }
}

/// Mixin for objects that support memory pooling.
mixin Poolable<T> {
  /// Resets the object to a reusable state.
  void reset();

  /// Gets a new instance from the pool or creates one.
  static T getFromPool<T>() {
    return MemoryManager().getObject<T>();
  }

  /// Returns this object to the pool for reuse.
  void returnToPool() {
    MemoryManager().returnObject(this);
  }
}
