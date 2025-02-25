import 'package:flutter_test/flutter_test.dart';
import 'package:json_placeholder_app/services/api_exception.dart';

void main() {
  group('ApiException', () {
    test('should create instance with message only', () {
      final exception = ApiException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, isNull);
      expect(exception.body, isNull);
      expect(exception.isTimeout, isFalse);
      expect(exception.isNetworkError, isFalse);
    });

    test('should create instance with all parameters', () {
      final exception = ApiException(
        'Test error',
        statusCode: 404,
        body: 'Not found',
        isTimeout: true,
        isNetworkError: true,
      );

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(404));
      expect(exception.body, equals('Not found'));
      expect(exception.isTimeout, isTrue);
      expect(exception.isNetworkError, isTrue);
    });

    test('toString should include message only when no other fields are set',
        () {
      final exception = ApiException('Test error');

      expect(exception.toString(), equals('ApiException: Test error'));
    });

    test('toString should include status code when provided', () {
      final exception = ApiException('Test error', statusCode: 404);

      expect(exception.toString(),
          equals('ApiException: Test error (Status code: 404)'));
    });

    test('toString should include timeout message when isTimeout is true', () {
      final exception = ApiException('Test error', isTimeout: true);

      expect(exception.toString(),
          equals('ApiException: Test error - Connection timed out'));
    });

    test(
        'toString should include network error message when isNetworkError is true',
        () {
      final exception = ApiException('Test error', isNetworkError: true);

      expect(exception.toString(),
          equals('ApiException: Test error - Network error'));
    });

    test('toString should include all information when all fields are set', () {
      final exception = ApiException(
        'Test error',
        statusCode: 500,
        body: 'Server error',
        isTimeout: true,
        isNetworkError: true,
      );

      expect(
          exception.toString(),
          equals(
              'ApiException: Test error (Status code: 500) - Connection timed out - Network error'));
    });
  });
}
