import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_app/models/post.dart';
import 'package:json_placeholder_app/providers/post_providers.dart';
import 'package:json_placeholder_app/models/comment.dart';

/// Creates a testable widget with Riverpod providers overridden for testing
Widget createProviderTestWidget({
  required Widget child,
  List<Post> posts = const [],
  bool isLoading = false,
  String? error,
  Map<int, List<Comment>> comments = const {},
  bool shouldThrowOnCreate = false,
  bool shouldThrowOnUpdate = false,
}) {
  final postsState = PostsState(
    posts: posts,
    isLoading: isLoading,
    error: error,
  );

  return ProviderScope(
    overrides: [
      // Override the posts notifier provider to use our test state
      postsNotifierProvider.overrideWith(() => TestPostsNotifier(
            postsState,
            shouldThrowOnCreate: shouldThrowOnCreate,
            shouldThrowOnUpdate: shouldThrowOnUpdate,
          )),

      // Create overrides for each postId in the comments map
      for (final entry in comments.entries)
        postCommentsProvider(entry.key).overrideWith(
          (ref) async => entry.value,
        ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

class TestPostsNotifier extends PostsNotifier {
  final PostsState _initialState;
  final bool shouldThrowOnCreate;
  final bool shouldThrowOnUpdate;

  TestPostsNotifier(
    this._initialState, {
    this.shouldThrowOnCreate = false,
    this.shouldThrowOnUpdate = false,
  });

  @override
  PostsState build() => _initialState;

  @override
  Future<void> fetchPosts({bool forceRefresh = false}) async {
    // No-op for tests
  }

  @override
  Future<void> createPost(Post post) async {
    if (shouldThrowOnCreate) {
      throw Exception('Test error during create');
    }

    // Add the post to state for testing
    state = state.copyWith(
      posts: [post.copyWith(id: 999), ...state.posts],
    );
  }

  @override
  Future<void> updatePost(Post post) async {
    if (shouldThrowOnUpdate) {
      throw Exception('Test error during update');
    }

    // Update the post in state for testing
    final updatedPosts = state.posts.map((p) {
      return p.id == post.id ? post : p;
    }).toList();

    state = state.copyWith(posts: updatedPosts);
  }
}
