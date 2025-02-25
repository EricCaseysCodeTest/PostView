import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_app/models/post.dart';
import 'package:json_placeholder_app/models/comment.dart';
import 'package:json_placeholder_app/providers/post_providers.dart';
import 'package:json_placeholder_app/repositories/post_repository.dart';
import 'package:json_placeholder_app/services/api_exception.dart';

@GenerateNiceMocks([MockSpec<PostRepository>()])
import 'post_providers_test.mocks.dart';

void main() {
  late MockPostRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockPostRepository();

    // Create a ProviderContainer with overridden repository provider
    container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    // Add a listener to the container to prevent "no listener" warnings
    addTearDown(container.dispose);
  });

  group('postsNotifierProvider', () {
    test('initial state should be empty with no loading or error', () {
      final state = container.read(postsNotifierProvider);

      expect(state.posts, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('fetchPosts should update state with posts from repository', () async {
      // Arrange
      final testPosts = [
        Post(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
        Post(id: 2, userId: 1, title: 'Test Post 2', body: 'Body 2'),
      ];
      when(mockRepository.getPosts()).thenAnswer((_) async => testPosts);

      // Act
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts, equals(testPosts));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      verify(mockRepository.getPosts()).called(1);
    });

    test('fetchPosts should set error state when repository throws', () async {
      // Arrange
      when(mockRepository.getPosts())
          .thenThrow(Exception('Failed to load posts'));

      // Act
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, contains('Failed to load posts'));
      verify(mockRepository.getPosts()).called(1);
    });

    test('createPost should add new post to state', () async {
      // Arrange
      final newPost = Post(userId: 1, title: 'New Post', body: 'New Body');
      final createdPost = Post(
        id: 101,
        userId: 1,
        title: 'New Post',
        body: 'New Body',
      );
      when(mockRepository.createPost(newPost))
          .thenAnswer((_) async => createdPost);

      // Act
      await container.read(postsNotifierProvider.notifier).createPost(newPost);

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts.length, equals(1));
      expect(state.posts.first, equals(createdPost));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      verify(mockRepository.createPost(newPost)).called(1);
    });

    test('createPost should set error state when repository throws', () async {
      // Arrange
      final newPost = Post(userId: 1, title: 'New Post', body: 'New Body');
      when(mockRepository.createPost(newPost))
          .thenThrow(Exception('Failed to create post'));

      // Act
      await container.read(postsNotifierProvider.notifier).createPost(newPost);

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, contains('Failed to create post'));
      verify(mockRepository.createPost(newPost)).called(1);
    });

    test('updatePost should update existing post in state', () async {
      // Arrange - First add a post to the state
      final initialPost =
          Post(id: 1, userId: 1, title: 'Initial', body: 'Body');
      final updatedPost = Post(
        id: 1,
        userId: 1,
        title: 'Updated Title',
        body: 'Updated Body',
      );

      // Mock repository to return the initial post first, then the updated post
      when(mockRepository.getPosts()).thenAnswer((_) async => [initialPost]);
      when(mockRepository.updatePost(updatedPost))
          .thenAnswer((_) async => updatedPost);

      // Add initial post to state
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Act - Update the post
      await container
          .read(postsNotifierProvider.notifier)
          .updatePost(updatedPost);

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts.length, equals(1));
      expect(state.posts.first.title, equals('Updated Title'));
      expect(state.posts.first.body, equals('Updated Body'));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      verify(mockRepository.updatePost(updatedPost)).called(1);
    });

    test('updatePost should set error state when repository throws', () async {
      // Arrange - First add a post to the state
      final initialPost =
          Post(id: 1, userId: 1, title: 'Initial', body: 'Body');
      final updatedPost = Post(
        id: 1,
        userId: 1,
        title: 'Updated Title',
        body: 'Updated Body',
      );

      // Mock repository
      when(mockRepository.getPosts()).thenAnswer((_) async => [initialPost]);
      when(mockRepository.updatePost(updatedPost))
          .thenThrow(Exception('Failed to update post'));

      // Add initial post to state
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Act - Try to update the post
      await container
          .read(postsNotifierProvider.notifier)
          .updatePost(updatedPost);

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts.length, equals(1));
      expect(
          state.posts.first.title, equals('Initial')); // Should not be updated
      expect(state.isLoading, isFalse);
      expect(state.error, contains('Failed to update post'));
      verify(mockRepository.updatePost(updatedPost)).called(1);
    });

    test('fetchPosts should not make duplicate calls when loading', () async {
      // Arrange
      final testPosts = [
        Post(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
      ];

      // Use a completer to control when the repository responds
      final completer = Completer<List<Post>>();
      when(mockRepository.getPosts()).thenAnswer((_) => completer.future);

      // Act - Start the first fetch (will be pending)
      final firstFetch =
          container.read(postsNotifierProvider.notifier).fetchPosts();

      // Verify loading state is set
      expect(container.read(postsNotifierProvider).isLoading, isTrue);

      // Try to fetch again while the first fetch is still in progress
      final secondFetch =
          container.read(postsNotifierProvider.notifier).fetchPosts();

      // Complete the repository call
      completer.complete(testPosts);

      // Wait for both fetches to complete
      await Future.wait([firstFetch, secondFetch]);

      // Assert
      final state = container.read(postsNotifierProvider);
      expect(state.posts, equals(testPosts));
      expect(state.isLoading, isFalse);

      // Verify repository was only called once
      verify(mockRepository.getPosts()).called(1);
    });

    test('fetchPosts should use cache when available and not forced to refresh',
        () async {
      // Arrange
      final testPosts = [
        Post(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
      ];
      when(mockRepository.getPosts()).thenAnswer((_) async => testPosts);

      // Act - First fetch to populate cache
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Reset the mock to verify it's not called again
      reset(mockRepository);

      // Second fetch should use cache
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Assert - Repository should not be called again
      verifyNever(mockRepository.getPosts());

      // State should still have the posts
      final state = container.read(postsNotifierProvider);
      expect(state.posts, equals(testPosts));
    });

    test('fetchPosts should ignore cache when forceRefresh is true', () async {
      // Arrange
      final initialPosts = [
        Post(id: 1, userId: 1, title: 'Initial Post', body: 'Body 1'),
      ];
      final updatedPosts = [
        Post(id: 1, userId: 1, title: 'Updated Post', body: 'Body 1'),
        Post(id: 2, userId: 1, title: 'New Post', body: 'Body 2'),
      ];

      // First return initial posts, then updated posts
      when(mockRepository.getPosts()).thenAnswer((_) async => initialPosts);

      // Act - First fetch to populate cache
      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Setup mock to return updated posts on second call
      when(mockRepository.getPosts()).thenAnswer((_) async => updatedPosts);

      // Second fetch with forceRefresh = true
      await container
          .read(postsNotifierProvider.notifier)
          .fetchPosts(forceRefresh: true);

      // Assert - Repository should be called twice
      verify(mockRepository.getPosts()).called(2);

      // State should have the updated posts
      final state = container.read(postsNotifierProvider);
      expect(state.posts, equals(updatedPosts));
    });

    test('clearError should remove error from state', () async {
      // Arrange - Create an error state
      when(mockRepository.getPosts())
          .thenThrow(Exception('Failed to load posts'));

      await container.read(postsNotifierProvider.notifier).fetchPosts();

      // Verify error is set
      expect(container.read(postsNotifierProvider).error, isNotNull);

      // Act - Clear the error
      container.read(postsNotifierProvider.notifier).clearError();

      // Assert
      expect(container.read(postsNotifierProvider).error, isNull);
    });

    test('clearError should do nothing if no error exists', () {
      // Act - Clear error when none exists
      container.read(postsNotifierProvider.notifier).clearError();

      // Assert - No error should still be no error
      expect(container.read(postsNotifierProvider).error, isNull);
    });

    test('PostsState.isCacheValid should return false when lastFetched is null',
        () {
      const state = PostsState();
      expect(state.isCacheValid, isFalse);
    });

    test('PostsState.isCacheValid should return true for recent fetch', () {
      final state = PostsState(
        lastFetched: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(state.isCacheValid, isTrue);
    });

    test('PostsState.isCacheValid should return false for old fetch', () {
      final state = PostsState(
        lastFetched: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      expect(state.isCacheValid, isFalse);
    });

    test('PostsState.copyWith should update specified fields', () {
      const initialState = PostsState(
        isLoading: true,
        error: 'Initial error',
      );

      final updatedState = initialState.copyWith(
        isLoading: false,
        error: 'New error',
      );

      expect(updatedState.isLoading, isFalse);
      expect(updatedState.error, equals('New error'));
    });

    test('PostsState.copyWith with clearError should set error to null', () {
      const initialState = PostsState(error: 'Some error');

      final updatedState = initialState.copyWith(clearError: true);

      expect(updatedState.error, isNull);
    });
  });

  group('postCommentsProvider', () {
    test('should return comments from repository', () async {
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
      ];
      when(mockRepository.getCommentsForPost(postId))
          .thenAnswer((_) async => testComments);

      // Act
      final commentsAsync = container.read(postCommentsProvider(postId));

      // Assert - Should be loading initially
      expect(commentsAsync, isA<AsyncLoading<List<Comment>>>());

      // Wait for the future to complete
      await container.read(postCommentsProvider(postId).future);

      // Get the updated state
      final commentsResult = container.read(postCommentsProvider(postId));

      // Assert - Should have data now
      expect(commentsResult, isA<AsyncData<List<Comment>>>());
      expect(commentsResult.value, equals(testComments));
      verify(mockRepository.getCommentsForPost(postId)).called(1);
    });

    test('should use cached comments when available', () async {
      // Arrange
      const postId = 1;
      final testComments = [
        Comment(
          id: 1,
          postId: postId,
          name: 'Comment 1',
          email: 'test@test.com',
          body: 'Comment Body 1',
          isTest: true,
        ),
      ];
      when(mockRepository.getCommentsForPost(postId))
          .thenAnswer((_) async => testComments);

      // Act - First call to populate cache
      await container.read(postCommentsProvider(postId).future);

      // Reset mock to verify it's not called again
      reset(mockRepository);

      // Second call should use cache
      final cachedResult =
          await container.read(postCommentsProvider(postId).future);

      // Assert - Compare properties instead of instances
      expect(cachedResult.length, equals(testComments.length));
      expect(cachedResult.first.id, equals(testComments.first.id));
      expect(cachedResult.first.postId, equals(testComments.first.postId));
      expect(cachedResult.first.name, equals(testComments.first.name));
      expect(cachedResult.first.email, equals(testComments.first.email));
      expect(cachedResult.first.body, equals(testComments.first.body));

      verifyNever(mockRepository.getCommentsForPost(postId));
    });

    test('should handle ApiException from repository', () async {
      // Create a fresh container to avoid cache interference
      final mockRepo = MockPostRepository();
      final testContainer = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(testContainer.dispose);

      // Arrange
      const postId = 10; // Use a unique ID
      final apiException = ApiException('API error', statusCode: 500);
      when(mockRepo.getCommentsForPost(postId)).thenThrow(apiException);

      // Act & Assert
      await expectLater(
        testContainer.read(postCommentsProvider(postId).future),
        throwsA(isA<ApiException>()),
      );

      // Verify the repository was called
      verify(mockRepo.getCommentsForPost(postId)).called(1);
    });

    test('should handle generic Exception from repository', () async {
      // Create a fresh container to avoid cache interference
      final mockRepo = MockPostRepository();
      final testContainer = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(testContainer.dispose);

      // Arrange
      const postId = 20; // Use a unique ID
      when(mockRepo.getCommentsForPost(postId))
          .thenThrow(Exception('Generic error'));

      // Act & Assert
      await expectLater(
        testContainer.read(postCommentsProvider(postId).future),
        throwsA(isA<Exception>()),
      );

      // Verify the repository was called
      verify(mockRepo.getCommentsForPost(postId)).called(1);
    });
  });
}
