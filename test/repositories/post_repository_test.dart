import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:json_placeholder_app/repositories/post_repository.dart';
import 'package:json_placeholder_app/services/api_service.dart';
import 'package:json_placeholder_app/models/post.dart';
import 'package:json_placeholder_app/models/comment.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
import 'post_repository_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late PostRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = PostRepository(apiService: mockApiService);
  });

  group('PostRepository', () {
    test('getPosts should return posts from API service', () async {
      // Arrange
      final testPosts = [
        Post(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
        Post(id: 2, userId: 1, title: 'Test Post 2', body: 'Body 2'),
      ];
      when(mockApiService.getPosts()).thenAnswer((_) async => testPosts);

      // Act
      final result = await repository.getPosts();

      // Assert
      expect(result, equals(testPosts));
      verify(mockApiService.getPosts()).called(1);
    });

    test('getCommentsForPost should return comments from API service',
        () async {
      // Arrange
      const postId = 1;
      final testComments = [
        Comment(
          id: 1,
          postId: postId,
          name: 'Comment 1',
          email: 'test@test.com',
          body: 'Comment Body 1',
        ),
        Comment(
          id: 2,
          postId: postId,
          name: 'Comment 2',
          email: 'test2@test.com',
          body: 'Comment Body 2',
        ),
      ];
      when(mockApiService.getCommentsForPost(postId))
          .thenAnswer((_) async => testComments);

      // Act
      final result = await repository.getCommentsForPost(postId);

      // Assert
      expect(result, equals(testComments));
      verify(mockApiService.getCommentsForPost(postId)).called(1);
    });

    test('createPost should return created post from API service', () async {
      // Arrange
      final newPost = Post(userId: 1, title: 'New Post', body: 'New Body');
      final createdPost = Post(
        id: 101,
        userId: 1,
        title: 'New Post',
        body: 'New Body',
      );
      when(mockApiService.createPost(newPost))
          .thenAnswer((_) async => createdPost);

      // Act
      final result = await repository.createPost(newPost);

      // Assert
      expect(result, equals(createdPost));
      verify(mockApiService.createPost(newPost)).called(1);
    });

    test('updatePost should return updated post from API service', () async {
      // Arrange
      final updatedPost = Post(
        id: 1,
        userId: 1,
        title: 'Updated Title',
        body: 'Updated Body',
      );
      when(mockApiService.updatePost(updatedPost))
          .thenAnswer((_) async => updatedPost);

      // Act
      final result = await repository.updatePost(updatedPost);

      // Assert
      expect(result, equals(updatedPost));
      verify(mockApiService.updatePost(updatedPost)).called(1);
    });

    test('getPosts should propagate exceptions from API service', () async {
      // Arrange
      when(mockApiService.getPosts())
          .thenThrow(Exception('Failed to load posts'));

      // Act & Assert
      expect(
        () => repository.getPosts(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load posts'),
        )),
      );
    });

    test('getCommentsForPost should propagate exceptions from API service',
        () async {
      // Arrange
      const postId = 1;
      when(mockApiService.getCommentsForPost(postId))
          .thenThrow(Exception('Failed to load comments'));

      // Act & Assert
      expect(
        () => repository.getCommentsForPost(postId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load comments'),
        )),
      );
    });

    test('createPost should propagate exceptions from API service', () async {
      // Arrange
      final newPost = Post(userId: 1, title: 'New Post', body: 'New Body');
      when(mockApiService.createPost(newPost))
          .thenThrow(Exception('Failed to create post'));

      // Act & Assert
      expect(
        () => repository.createPost(newPost),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to create post'),
        )),
      );
    });

    test('updatePost should propagate exceptions from API service', () async {
      // Arrange
      final updatedPost = Post(
        id: 1,
        userId: 1,
        title: 'Updated Title',
        body: 'Updated Body',
      );
      when(mockApiService.updatePost(updatedPost))
          .thenThrow(Exception('Failed to update post'));

      // Act & Assert
      expect(
        () => repository.updatePost(updatedPost),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to update post'),
        )),
      );
    });
  });
}
