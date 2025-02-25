import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:json_placeholder_app/main.dart' as app;
import 'package:json_placeholder_app/screens/posts_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Create and view post flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Integration Test Title',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Integration Test Body',
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);

      expect(find.text('Integration Test Title'), findsOneWidget);
    });

    testWidgets('Edit post and form validation flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      // First test empty form validation
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title'), findsOneWidget);
      expect(find.text('Please enter a body'), findsOneWidget);

      // Fill only title to test partial validation
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Test Title',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a body'), findsOneWidget);
      expect(find.text('Please enter a title'), findsNothing);

      // Go back to posts screen
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Now test edit flow
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Post'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Updated Title',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'Updated Body',
      );

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);

      // Verify the post was actually updated
      expect(find.text('Updated Title'), findsOneWidget);
      expect(find.text('Updated Body'), findsOneWidget);

      // Test edge cases with very long inputs
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'A' * 100,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body'),
        'B' * 200,
      );

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();
    });

    testWidgets('View comments and error handling', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      // Test comments viewing
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      // Verify that actual comment content is displayed
      expect(find.byIcon(Icons.comment), findsWidgets);
      expect(find.textContaining('@'), findsWidgets); // Email in comment

      // Find at least one comment with text content
      expect(
        find.byWidgetPredicate((widget) {
          // Find comment text that isn't just the email or name
          if (widget is Text &&
              widget.data != null &&
              widget.data!.length > 20 &&
              !widget.data!.contains('@')) {
            return true;
          }
          return false;
        }),
        findsWidgets,
      );

      // Test comment expansion memory management
      await tester.tap(find.byType(ExpansionTile).first); // Collapse
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ExpansionTile).at(1)); // Expand another
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ListTile), findsWidgets);

      // Test error handling
      // This might show an error or might load successfully depending on network
      // We're just making sure the app doesn't crash
      await tester.dragFrom(
        tester.getCenter(find.byType(ListView)),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Post list scroll and navigation state preservation',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test scrolling
      await tester.dragFrom(
        tester.getCenter(find.byType(ListView)),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PostCard), findsWidgets);

      // Test navigation state preservation
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Test Title',
      );

      // Simulate app lifecycle events
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, 'Test Title'),
        findsOneWidget,
      );
    });
  });
}
