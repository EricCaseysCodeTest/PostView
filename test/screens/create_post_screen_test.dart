import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_placeholder_app/screens/create_post_screen.dart';
import 'package:json_placeholder_app/models/post.dart';
import '../helpers/test_helpers.dart';

void main() {
  Widget createTestWidget({
    Post? post,
    bool shouldThrowOnCreate = false,
    bool shouldThrowOnUpdate = false,
  }) {
    return createProviderTestWidget(
      child: CreatePostScreen(post: post),
      shouldThrowOnCreate: shouldThrowOnCreate,
      shouldThrowOnUpdate: shouldThrowOnUpdate,
    );
  }

  testWidgets('renders form fields correctly in create mode', (tester) async {
    // ARRANGE
    await tester.pumpWidget(createTestWidget());

    // ASSERT
    expect(find.text('Create Post'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);

    // Find TextFormFields by their type and index
    final titleField = find.byType(TextFormField).at(0);
    final bodyField = find.byType(TextFormField).at(1);

    // Fill form
    await tester.enterText(titleField, 'Test Title');
    await tester.enterText(bodyField, 'Test Body');

    // Submit form
    await tester.tap(find.text('Create'));

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle();

    // Verify navigation occurred (widget is no longer in the tree)
    expect(find.text('Create Post'), findsNothing);
  });

  testWidgets('renders and submits form correctly in edit mode',
      (tester) async {
    // ARRANGE
    final post =
        Post(id: 1, userId: 1, title: 'Original Title', body: 'Original Body');
    await tester.pumpWidget(createTestWidget(
      post: post,
    ));

    // ASSERT initial state
    expect(find.text('Edit Post'), findsOneWidget);
    expect(find.text('Original Title'), findsOneWidget);
    expect(find.text('Original Body'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    // Find TextFormFields by their type and index
    final titleField = find.byType(TextFormField).at(0);
    final bodyField = find.byType(TextFormField).at(1);

    // ACT - edit fields
    await tester.enterText(titleField, 'Updated Title');
    await tester.enterText(bodyField, 'Updated Body');

    // Submit form
    await tester.tap(find.text('Update'));

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle();

    // Verify navigation occurred (widget is no longer in the tree)
    expect(find.text('Edit Post'), findsNothing);
  });

  testWidgets('handles error during form submission', (tester) async {
    // ARRANGE
    await tester.pumpWidget(createTestWidget(shouldThrowOnCreate: true));

    // Find TextFormFields by their type and index
    final titleField = find.byType(TextFormField).at(0);
    final bodyField = find.byType(TextFormField).at(1);

    // Fill form
    await tester.enterText(titleField, 'Test Title');
    await tester.enterText(bodyField, 'Test Body');

    // Submit form
    await tester.tap(find.text('Create'));

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle();

    // ASSERT - error is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error: Exception: Test error during create'),
        findsOneWidget);

    // Form should still be visible (no navigation)
    expect(find.text('Create Post'), findsOneWidget);

    // Button should be enabled again after error
    final buttonFinder = find.widgetWithText(ElevatedButton, 'Create');
    final button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('handles error during post update', (tester) async {
    // ARRANGE
    final post =
        Post(id: 1, userId: 1, title: 'Original Title', body: 'Original Body');
    await tester
        .pumpWidget(createTestWidget(post: post, shouldThrowOnUpdate: true));

    // Find TextFormFields by their type and index
    final titleField = find.byType(TextFormField).at(0);
    final bodyField = find.byType(TextFormField).at(1);

    // Fill form
    await tester.enterText(titleField, 'Updated Title');
    await tester.enterText(bodyField, 'Updated Body');

    // Submit form
    await tester.tap(find.text('Update'));

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle();

    // ASSERT - error is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error: Exception: Test error during update'),
        findsOneWidget);

    // Form should still be visible (no navigation)
    expect(find.text('Edit Post'), findsOneWidget);

    // Button should be enabled again after error
    final buttonFinder = find.widgetWithText(ElevatedButton, 'Update');
    final button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNotNull);
  });
}
