import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/memory/memory_manager.dart';
import 'package:snakes_fight/core/models/position.dart';

void main() {
  group('MemoryManager', () {
    late MemoryManager memoryManager;

    setUp(() {
      MemoryManager.reset();
      memoryManager = MemoryManager();
    });

    tearDown(() {
      MemoryManager.reset();
    });

    group('initialization', () {
      test('should initialize successfully', () {
        final stats = memoryManager.getMemoryStats();
        expect(stats['allocation_count'], equals(0));
        expect(stats['pool_hit_count'], equals(0));
      });
    });

    group('object pooling', () {
      test('should create objects when pool is empty', () {
        final position = memoryManager.getObject<Position>();
        
        expect(position, isA<Position>());
        
        final stats = memoryManager.getMemoryStats();
        expect(stats['allocation_count'], equals(1));
        expect(stats['pool_hit_count'], equals(0));
      });

      test('should reuse objects from pool', () {
        // Reset stats to start fresh
        memoryManager.dispose();
        memoryManager = MemoryManager();
        memoryManager.initialize();
        
        // Create and return an object
        final position1 = memoryManager.getObject<Position>();
        memoryManager.returnObject(position1);
        
        // Get another object (should come from pool)
        memoryManager.getObject<Position>();
        
        final stats = memoryManager.getMemoryStats();
        expect(stats['allocation_count'], equals(1));
        expect(stats['pool_hit_count'], equals(1));
      });

      test('should calculate hit rate correctly', () {
        memoryManager.initialize();
        
        // Create several objects
        final pos1 = memoryManager.getObject<Position>();
        final pos2 = memoryManager.getObject<Position>();
        memoryManager.getObject<Position>();
        
        // Return some to pool
        memoryManager.returnObject(pos1);
        memoryManager.returnObject(pos2);
        
        // Get from pool (these should be hits)
        memoryManager.getObject<Position>();
        memoryManager.getObject<Position>();
        
        final stats = memoryManager.getMemoryStats();
        final hitRate = stats['hit_rate'] as double;
        
        expect(hitRate, greaterThan(0.0));
        expect(hitRate, lessThanOrEqualTo(1.0));
      });
    });

    group('statistics', () {
      test('should provide accurate memory statistics', () {
        // Reset for clean test
        memoryManager.dispose();
        memoryManager = MemoryManager();
        memoryManager.initialize();
        
        memoryManager.getObject<Position>();
        memoryManager.getObject<Position>();
        
        final stats = memoryManager.getMemoryStats();
        
        expect(stats, containsPair('allocation_count', 2));
        expect(stats, containsPair('pool_hit_count', 0));
        expect(stats, containsPair('hit_rate', 0.0));
        expect(stats, containsPair('total_pooled_objects', 0));
        expect(stats['pool_sizes'], isA<Map>());
        expect(stats['pool_capacities'], isA<Map>());
      });
    });

    group('memory optimization', () {
      test('should optimize memory without errors', () {
        // Create some objects to pool
        for (int i = 0; i < 10; i++) {
          final pos = memoryManager.getObject<Position>();
          memoryManager.returnObject(pos);
        }
        
        expect(() => memoryManager.optimizeMemory(), returnsNormally);
      });
    });
  });

  group('ObjectPool', () {
    late ObjectPool<Position> pool;

    setUp(() {
      pool = ObjectPool<Position>(
        createFn: () => const Position(0, 0),
        resetFn: (pos) {}, // Position is immutable
        maxSize: 5,
      );
    });

    test('should return null when empty', () {
      final obj = pool.get();
      expect(obj, isNull);
    });

    test('should store and retrieve objects', () {
      const testPosition = Position(1, 2);
      
      pool.returnToPool(testPosition);
      final retrieved = pool.get();
      
      expect(retrieved, isNotNull);
      expect(pool.size, equals(0));
    });

    test('should respect max size', () {
      // Add more objects than max size
      for (int i = 0; i < 10; i++) {
        pool.returnToPool(Position(i, i));
      }
      
      expect(pool.size, equals(5)); // Should be capped at maxSize
    });

    test('should trim pool correctly', () {
      // Fill pool to capacity
      for (int i = 0; i < 5; i++) {
        pool.returnToPool(Position(i, i));
      }
      
      pool.trim();
      
      expect(pool.size, equals(2)); // Should be half of maxSize (5/2 = 2)
    });

    test('should clear pool', () {
      pool.returnToPool(const Position(1, 1));
      pool.returnToPool(const Position(2, 2));
      
      pool.clear();
      
      expect(pool.size, equals(0));
    });
  });
}
