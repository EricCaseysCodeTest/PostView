# PostView

A Flutter application that demonstrates interaction with the JSONPlaceholder API, per the Caseys Technical Interview document.

## Project Overview

PostView allows users to:

- View a list of posts from the JSONPlaceholder API
- Create new posts (simulated)
- Edit existing posts (simulated)
- View comments for each post

The app is built with:

- **Flutter** for cross-platform UI development
- **Riverpod** for state management
- **HTTP package** for API communication
- **Comprehensive testing** including unit, widget, and integration tests

## Architecture

The project contains the following architecture:

- **Models**: Data classes representing posts and comments
- **Services**: API communication layer
- **Repositories**: Business logic layer
- **Providers**: State management using Riverpod
- **Screens**: UI components

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Dart SDK
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)
- A mobile device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd postview
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Running Tests

### Unit and Widget Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/screens/create_post_screen_test.dart
```

### Integration Tests

Run integration tests:
```bash
flutter test integration_test/app_test.dart
```

### Test Coverage

Generate test coverage:
```bash
flutter test --coverage
```

View coverage report (requires lcov):
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Features

### Posts Screen
- Displays a list of posts fetched from the API
- Each post can be expanded to view comments
- Floating action button to create new posts
- Edit button for each post

### Create/Edit Post Screen
- Form to create or edit posts
- Form validation
- Loading indicator during submission
- Error handling

### Comments
- Comments are loaded on-demand when a post is expanded
- Loading indicator while comments are being fetched
- Error handling for failed comment loading

## Notes

- The JSONPlaceholder API doesn't actually persist new posts or updates, so these operations are simulated in the app.
- Changes to posts won't exist on the server or in the app if it's restarted.

## Project Structure

```
lib/
├── models/          # Data models
├── providers/       # Riverpod providers
├── repositories/    # Business logic
├── screens/         # UI screens
├── services/        # API services
└── main.dart        # App entry point

test/
├── helpers/         # Test helpers
├── models/          # Model tests
├── providers/       # Provider tests
├── screens/         # Screen tests
└── services/        # Service tests

integration_test/
└── app_test.dart    # Integration tests
```

## Known Limitations

- JSONPlaceholder API doesn't persist changes
- Changes are only reflected in local state
- No offline support

## Future Improvements

- Add offline support using local storage
- Implement pagination for posts list
- Add search and filtering
- Enhance error recovery mechanisms