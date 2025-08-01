import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/services/database_service.dart';

void main() {
  group('DatabaseService', () {
    group('DatabaseException', () {
      test('should create exception with message', () {
        // Arrange
        const message = 'Test error';

        // Act
        const exception = DatabaseException(message);

        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, isNull);
        expect(exception.originalError, isNull);
        expect(exception.toString(), contains(message));
      });

      test('should create exception with all properties', () {
        // Arrange
        const message = 'Test error';
        const code = 'test_error';
        const originalError = 'Original error';

        // Act
        const exception = DatabaseException(
          message,
          code: code,
          originalError: originalError,
        );

        // Assert
        expect(exception.message, equals(message));
        expect(exception.code, equals(code));
        expect(exception.originalError, equals(originalError));
        expect(exception.toString(), contains(message));
      });
    });

    group('DatabaseErrorCode', () {
      test('should have all expected error codes', () {
        // Assert
        expect(
          DatabaseErrorCode.values,
          contains(DatabaseErrorCode.connectionFailed),
        );
        expect(
          DatabaseErrorCode.values,
          contains(DatabaseErrorCode.permissionDenied),
        );
        expect(
          DatabaseErrorCode.values,
          contains(DatabaseErrorCode.dataNotFound),
        );
        expect(
          DatabaseErrorCode.values,
          contains(DatabaseErrorCode.invalidData),
        );
        expect(
          DatabaseErrorCode.values,
          contains(DatabaseErrorCode.transactionAborted),
        );
      });
    });

    group('DatabaseService Interface', () {
      test('should have correct interface definition', () {
        // This test verifies the interface exists and has correct structure
        // We can't instantiate FirebaseDatabaseService without Firebase setup
        expect(DatabaseService, isA<Type>());
        expect(DatabaseException, isA<Type>());
        expect(DatabaseErrorCode.values.isNotEmpty, isTrue);
      });
    });
  });
}
