import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class PostRepository {
  final ApiService _apiService;

  PostRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<Post>> getPosts() async {
    try {
      return await _apiService.getPosts();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    try {
      return await _apiService.getCommentsForPost(postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Post> createPost(Post post) async {
    try {
      return await _apiService.createPost(post);
    } catch (e) {
      rethrow;
    }
  }

  Future<Post> updatePost(Post post) async {
    try {
      return await _apiService.updatePost(post);
    } catch (e) {
      rethrow;
    }
  }
}
