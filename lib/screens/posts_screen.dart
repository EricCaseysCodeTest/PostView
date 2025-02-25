import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/post_providers.dart';
import '../models/post.dart';
import 'create_post_screen.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsNotifierProvider.notifier).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsNotifierProvider);
    final posts = postsState.posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Column(
        children: [
          Expanded(
            child: postsState.error != null
                ? Center(
                    child: Text('Error: ${postsState.error}'),
                  )
                : postsState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: posts[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          post.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          post.body,
          style: const TextStyle(color: Colors.black87),
        ),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePostScreen(post: post),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ),
          ),
          CommentsSection(postId: post.id!),
        ],
      ),
    );
  }
}

class CommentsSection extends ConsumerStatefulWidget {
  final int postId;

  const CommentsSection({super.key, required this.postId});

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    return commentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Failed to load comments')),
      ),
      data: (comments) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          return ListTile(
            title: Text(
              comment.name,
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Text(
              comment.body,
              style: const TextStyle(color: Colors.black87),
            ),
            leading: const Icon(Icons.comment),
          );
        },
      ),
    );
  }
}
