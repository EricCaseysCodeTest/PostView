import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../models/comment.dart';
import '../repositories/post_repository.dart';
import '../services/api_exception.dart';

part 'post_providers.g.dart';

// Cache duration
const cacheDuration = Duration(minutes: 5);

// Repository provider
@riverpod
PostRepository postRepository(Ref ref) {
  return PostRepository();
}

// Posts state class with caching
class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final DateTime? lastFetched;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.lastFetched,
  });

  bool get isCacheValid {
    if (lastFetched == null) return false;
    final now = DateTime.now();
    return now.difference(lastFetched!) < cacheDuration;
  }

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    DateTime? lastFetched,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}

// Posts notifier with improved error handling and caching
@riverpod
class PostsNotifier extends _$PostsNotifier {
  @override
  PostsState build() {
    return const PostsState();
  }

  Future<void> fetchPosts({bool forceRefresh = false}) async {
    // Return cached data if it's still valid and not forcing refresh
    if (!forceRefresh && state.isCacheValid && state.posts.isNotEmpty) {
      return;
    }

    // Don't fetch if already loading
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final posts = await ref.read(postRepositoryProvider).getPosts();
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        lastFetched: DateTime.now(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<void> createPost(Post post) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final newPost = await ref.read(postRepositoryProvider).createPost(post);
      state = state.copyWith(
        posts: [newPost, ...state.posts],
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create post: $e',
      );
    }
  }

  Future<void> updatePost(Post post) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedPost =
          await ref.read(postRepositoryProvider).updatePost(post);

      final updatedPosts = state.posts.map((p) {
        return p.id == post.id ? updatedPost : p;
      }).toList();

      state = state.copyWith(
        posts: updatedPosts,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update post: $e',
      );
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

// Comments cache
final _commentsCache = <int, AsyncValue<List<Comment>>>{};
final _commentsCacheTimestamp = <int, DateTime>{};

// Comments provider with caching
@riverpod
Future<List<Comment>> postComments(
  Ref ref,
  int postId,
) async {
  // Check if we have a valid cache
  final now = DateTime.now();
  final timestamp = _commentsCacheTimestamp[postId];
  if (timestamp != null &&
      now.difference(timestamp) < cacheDuration &&
      _commentsCache[postId] != null) {
    final cachedValue = _commentsCache[postId]!;
    if (!cachedValue.isLoading && !cachedValue.hasError) {
      return cachedValue.value!;
    }
  }

  try {
    final comments =
        await ref.read(postRepositoryProvider).getCommentsForPost(postId);

    // Update cache
    _commentsCache[postId] = AsyncValue.data(comments);
    _commentsCacheTimestamp[postId] = now;

    return comments;
  } catch (e) {
    // Update cache with error
    final error =
        e is ApiException ? e : Exception('Failed to load comments: $e');
    _commentsCache[postId] = AsyncValue.error(error, StackTrace.current);
    // Rethrow to ensure the error is propagated
    throw error;
  }
}
