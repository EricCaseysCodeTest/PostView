import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_placeholder_app/screens/posts_screen.dart';
import 'package:json_placeholder_app/models/post.dart';
import 'package:json_placeholder_app/models/comment.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PostsScreen', () {
    testWidgets('shows loading indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createProviderTestWidget(
          child: const PostsScreen(),
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays posts when loaded', (WidgetTester tester) async {
      final posts = [
        Post(id: 1, title: 'Post 1', body: 'Body 1', userId: 1),
        Post(id: 2, title: 'Post 2', body: 'Body 2', userId: 1),
      ];

      await tester.pumpWidget(
        createProviderTestWidget(
          child: const PostsScreen(),
          posts: posts,
        ),
      );

      expect(find.text('Post 1'), findsOneWidget);
      expect(find.text('Post 2'), findsOneWidget);
    });

    testWidgets('shows error state when posts fail to load',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createProviderTestWidget(
          child: const PostsScreen(),
          error: 'Failed to load posts: 500',
        ),
      );

      expect(find.text('Error: Failed to load posts: 500'), findsOneWidget);
    });

    testWidgets('navigates to create screen on FAB tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createProviderTestWidget(
          child: const PostsScreen(),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);
    });

    testWidgets('handles post expansion and comments loading', (tester) async {
      final post = Post(id: 1, userId: 1, title: 'Test Post', body: 'Body');
      final testComments = [
        Comment(
          id: 1,
          postId: 1,
          name: 'Comment 1',
          email: 'test@test.com',
          body: 'Comment Body',
        ),
      ];

      await tester.pumpWidget(
        createProviderTestWidget(
          child: const PostsScreen(),
          posts: [post],
          comments: {1: testComments},
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Comments should be visible
      expect(find.text('Comment 1'), findsOneWidget);
    });
  });

  group('PostCard', () {
    final testPost = Post(id: 1, userId: 1, title: 'Test Post', body: 'Body');
    final testComments = [
      Comment(
        id: 1,
        postId: 1,
        name: 'Comment 1',
        email: 'test@test.com',
        body: 'Comment Body',
      ),
    ];

    testWidgets('expands to show comments on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        createProviderTestWidget(
          child: MaterialApp(
            home: Scaffold(body: PostCard(post: testPost)),
          ),
          comments: {1: testComments},
        ),
      );

      // Initially comments should not be visible
      expect(find.text('Comment 1'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));

      // Allow expansion animation to complete
      await tester.pumpAndSettle();

      // Comments should be visible
      expect(find.text('Comment 1'), findsOneWidget);
    });
  });
}
