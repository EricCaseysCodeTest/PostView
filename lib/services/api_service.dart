import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';
import 'api_exception.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _defaultTimeout = Duration(seconds: 10);

  final http.Client _client;

  ApiService([http.Client? client]) : _client = client ?? http.Client();

  /// Checks if the device has internet connectivity
  Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Generic method to handle API requests with proper error handling
  Future<T> _handleRequest<T>({
    required Future<http.Response> Function() requestFunction,
    required T Function(dynamic data) processResponse,
    String errorMessage = 'API request failed',
    Duration timeout = _defaultTimeout,
    int maxRetries = 2,
  }) async {
    if (!await _hasNetworkConnection()) {
      throw ApiException('No internet connection', isNetworkError: true);
    }

    int attempts = 0;
    while (attempts <= maxRetries) {
      try {
        final response = await requestFunction().timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final dynamic data = json.decode(response.body);
          return processResponse(data);
        } else {
          throw ApiException(
            errorMessage,
            statusCode: response.statusCode,
            body: response.body,
          );
        }
      } on TimeoutException {
        if (attempts == maxRetries) {
          throw ApiException('Connection timed out', isTimeout: true);
        }
      } on SocketException {
        if (attempts == maxRetries) {
          throw ApiException('Network error', isNetworkError: true);
        }
      } catch (e) {
        if (e is ApiException || attempts == maxRetries) {
          rethrow;
        }
      }

      attempts++;
      if (attempts <= maxRetries) {
        await Future.delayed(Duration(milliseconds: 300 * (1 << attempts)));
      }
    }

    throw ApiException('Unknown error occurred');
  }

  Future<List<Post>> getPosts() async {
    return _handleRequest<List<Post>>(
      requestFunction: () => _client.get(Uri.parse('$baseUrl/posts')),
      processResponse: (data) =>
          (data as List).map((json) => Post.fromJson(json)).toList(),
      errorMessage: 'Failed to load posts',
    );
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    return _handleRequest<List<Comment>>(
      requestFunction: () => _client.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
      ),
      processResponse: (data) =>
          (data as List).map((json) => Comment.fromJson(json)).toList(),
      errorMessage: 'Failed to load comments for post $postId',
    );
  }

  Future<Post> createPost(Post post) async {
    return _handleRequest<Post>(
      requestFunction: () => _client.post(
        Uri.parse('$baseUrl/posts'),
        body: json.encode({
          'title': post.title,
          'body': post.body,
          'userId': post.userId,
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      ),
      processResponse: (data) => Post.fromJson(data),
      errorMessage: 'Failed to create post',
    );
  }

  Future<Post> updatePost(Post post) async {
    // For newly created posts (ID > 100), JSONPlaceholder will return 500
    // So we'll just simulate a successful update
    if (post.id != null && post.id! > 100) {
      return post;
    }

    return _handleRequest<Post>(
      requestFunction: () => _client.put(
        Uri.parse('$baseUrl/posts/${post.id}'),
        body: json.encode({
          'id': post.id,
          'title': post.title,
          'body': post.body,
          'userId': post.userId,
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      ),
      processResponse: (data) => Post.fromJson(data),
      errorMessage: 'Failed to update post ${post.id}',
    );
  }
}
