import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService(
        defaultTtl: const Duration(milliseconds: 100),
      );
    });

    tearDown(() {
      cacheService.clear();
    });

    test('should cache and retrieve values', () {
      const key = 'test_key';
      const value = 'test_value';

      cacheService.set(key, value);
      final cached = cacheService.get<String>(key);

      expect(cached, equals(value));
    });

    test('should return null for non-existent keys', () {
      final cached = cacheService.get<String>('non_existent');
      expect(cached, isNull);
    });

    test('should expire entries after TTL', () async {
      const key = 'expiring_key';
      const value = 'expiring_value';

      cacheService.set(key, value, ttl: const Duration(milliseconds: 50));

      // Should be available immediately
      expect(cacheService.get<String>(key), equals(value));

      // Wait for expiry
      await Future.delayed(const Duration(milliseconds: 100));

      // Should be expired
      expect(cacheService.get<String>(key), isNull);
    });

    test('should invalidate specific keys', () {
      const key1 = 'key1';
      const key2 = 'key2';
      const value1 = 'value1';
      const value2 = 'value2';

      cacheService.set(key1, value1);
      cacheService.set(key2, value2);

      cacheService.invalidate(key1);

      expect(cacheService.get<String>(key1), isNull);
      expect(cacheService.get<String>(key2), equals(value2));
    });

    test('should clear all cache entries', () {
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');

      expect(cacheService.size, equals(2));

      cacheService.clear();

      expect(cacheService.size, equals(0));
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), isNull);
    });

    test('should use getOrSet pattern', () async {
      const key = 'factory_key';
      const value = 'factory_value';
      var callCount = 0;

      Future<String> factory() async {
        callCount++;
        return value;
      }

      // First call should invoke factory
      final result1 = await cacheService.getOrSet(key, factory);
      expect(result1, equals(value));
      expect(callCount, equals(1));

      // Second call should use cache
      final result2 = await cacheService.getOrSet(key, factory);
      expect(result2, equals(value));
      expect(callCount, equals(1)); // Factory not called again
    });

    test('should cleanup expired entries', () async {
      cacheService.set('key1', 'value1', ttl: const Duration(milliseconds: 50));
      cacheService.set('key2', 'value2', ttl: const Duration(seconds: 10));

      expect(cacheService.size, equals(2));

      // Wait for first entry to expire
      await Future.delayed(const Duration(milliseconds: 100));

      cacheService.cleanup();

      expect(cacheService.size, equals(1));
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), equals('value2'));
    });

    test('should track cache statistics', () {
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');

      expect(cacheService.size, equals(2));
      expect(cacheService.keys, containsAll(['key1', 'key2']));
    });

    test('should handle different data types', () {
      cacheService.set('string_key', 'string_value');
      cacheService.set('int_key', 42);
      cacheService.set('list_key', [1, 2, 3]);
      cacheService.set('map_key', {'test': 'data'});

      expect(cacheService.get<String>('string_key'), equals('string_value'));
      expect(cacheService.get<int>('int_key'), equals(42));
      expect(cacheService.get<List<int>>('list_key'), equals([1, 2, 3]));
      expect(
        cacheService.get<Map<String, String>>('map_key'),
        equals({'test': 'data'}),
      );
    });
  });

  group('CacheEntry', () {
    test('should detect expired entries', () {
      final expiredEntry = CacheEntry(
        value: 'test',
        expiry: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      final validEntry = CacheEntry(
        value: 'test',
        expiry: DateTime.now().add(const Duration(seconds: 1)),
      );

      expect(expiredEntry.isExpired, isTrue);
      expect(validEntry.isExpired, isFalse);
    });
  });
}
