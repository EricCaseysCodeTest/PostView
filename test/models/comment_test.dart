import 'package:flutter_test/flutter_test.dart';
import 'package:json_placeholder_app/models/comment.dart';

void main() {
  group('Comment', () {
    test('fromJson creates Comment instance', () {
      final json = {
        'id': 1,
        'postId': 2,
        'name': 'Test Name',
        'email': 'test@test.com',
        'body': 'Test Body',
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, equals(1));
      expect(comment.postId, equals(2));
      expect(comment.name, equals('Test Name'));
      expect(comment.email, equals('test@test.com'));
      expect(comment.body, equals('Test Body'));
    });

    test('toJson creates correct map', () {
      final comment = Comment(
        id: 1,
        postId: 2,
        name: 'Test Name',
        email: 'test@test.com',
        body: 'Test Body',
      );

      final json = comment.toJson();

      expect(json['id'], equals(1));
      expect(json['postId'], equals(2));
      expect(json['name'], equals('Test Name'));
      expect(json['email'], equals('test@test.com'));
      expect(json['body'], equals('Test Body'));
    });

    test('constructor throws ArgumentError for invalid postId', () {
      expect(
          () => Comment(
                postId: 0,
                name: 'Test Name',
                email: 'test@test.com',
                body: 'Test Body',
              ),
          throwsArgumentError);

      expect(
          () => Comment(
                postId: -1,
                name: 'Test Name',
                email: 'test@test.com',
                body: 'Test Body',
              ),
          throwsArgumentError);
    });

    test('constructor throws ArgumentError for empty name', () {
      expect(
          () => Comment(
                postId: 1,
                name: '',
                email: 'test@test.com',
                body: 'Test Body',
              ),
          throwsArgumentError);
    });

    test('constructor throws ArgumentError for empty email', () {
      expect(
          () => Comment(
                postId: 1,
                name: 'Test Name',
                email: '',
                body: 'Test Body',
              ),
          throwsArgumentError);
    });

    test('constructor does not validate when isTest is true', () {
      // Should not throw even with invalid data
      final comment = Comment(
        postId: 0,
        name: '',
        email: '',
        body: 'Test Body',
        isTest: true,
      );

      expect(comment.postId, equals(0));
      expect(comment.name, equals(''));
      expect(comment.email, equals(''));
    });

    test('fromJson throws FormatException for missing postId', () {
      final json = {
        'id': 1,
        'name': 'Test Name',
        'email': 'test@test.com',
        'body': 'Test Body',
      };

      expect(() => Comment.fromJson(json), throwsFormatException);
    });

    test('fromJson throws FormatException for missing name', () {
      final json = {
        'id': 1,
        'postId': 2,
        'email': 'test@test.com',
        'body': 'Test Body',
      };

      expect(() => Comment.fromJson(json), throwsFormatException);
    });

    test('fromJson throws FormatException for missing email', () {
      final json = {
        'id': 1,
        'postId': 2,
        'name': 'Test Name',
        'body': 'Test Body',
      };

      expect(() => Comment.fromJson(json), throwsFormatException);
    });

    test('fromJson throws FormatException for missing body', () {
      final json = {
        'id': 1,
        'postId': 2,
        'name': 'Test Name',
        'email': 'test@test.com',
      };

      expect(() => Comment.fromJson(json), throwsFormatException);
    });

    test('fromJson throws FormatException for invalid postId', () {
      final json = {
        'id': 1,
        'postId': 0,
        'name': 'Test Name',
        'email': 'test@test.com',
        'body': 'Test Body',
      };

      expect(() => Comment.fromJson(json), throwsFormatException);
    });

    test('fromJson handles string postId', () {
      final json = {
        'id': 1,
        'postId': '2',
        'name': 'Test Name',
        'email': 'test@test.com',
        'body': 'Test Body',
      };

      final comment = Comment.fromJson(json);
      expect(comment.postId, equals(2));
    });

    test('fromJson skips validation when isTest is true', () {
      final json = {
        'id': 1,
        'postId': 0, // Invalid
        'name': '', // Invalid
        'email': '', // Invalid
        'body': 'Test Body',
      };

      // Should not throw with isTest = true
      final comment = Comment.fromJson(json, isTest: true);
      expect(comment.postId, equals(0));
      expect(comment.name, equals(''));
      expect(comment.email, equals(''));
    });

    test('copyWith creates a new instance with updated values', () {
      final original = Comment(
        id: 1,
        postId: 2,
        name: 'Original Name',
        email: 'original@test.com',
        body: 'Original Body',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        email: 'updated@test.com',
      );

      // Check updated fields
      expect(updated.name, equals('Updated Name'));
      expect(updated.email, equals('updated@test.com'));

      // Check unchanged fields
      expect(updated.id, equals(original.id));
      expect(updated.postId, equals(original.postId));
      expect(updated.body, equals(original.body));

      // Verify it's a new instance
      expect(identical(original, updated), isFalse);
    });

    test('copyWith with isTest parameter', () {
      final original = Comment(
        id: 1,
        postId: 2,
        name: 'Original Name',
        email: 'original@test.com',
        body: 'Original Body',
        isTest: false,
      );

      final updated = original.copyWith(isTest: true);

      expect(updated.isTest, isTrue);
      expect(original.isTest, isFalse);
    });
  });
}
