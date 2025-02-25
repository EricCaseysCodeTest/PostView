import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'screens/posts_screen.dart';

// Custom observer for Riverpod to log state changes and errors
class LoggingProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider ${provider.name ?? provider.runtimeType} updated: $newValue',
    );
  }

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider ${provider.name ?? provider.runtimeType} added: $value',
    );
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider ${provider.name ?? provider.runtimeType} error: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    developer.log('Flutter error caught:',
        error: details.exception, stackTrace: details.stack);
  };

  runApp(
    ProviderScope(
      observers: [LoggingProviderObserver()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PostView',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE10800),
          brightness: Brightness.light,
          surface: Colors.white,
          surfaceContainerLow: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE10800),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE10800),
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE10800),
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[850],
        textTheme: Typography.whiteMountainView,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[700],
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const PostsScreen(),
    );
  }
}
