import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../providers/post_providers.dart';

// Local provider for managing loading state
final _loadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class CreatePostScreen extends ConsumerStatefulWidget {
  final Post? post;

  const CreatePostScreen({super.key, this.post});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title);
    _bodyController = TextEditingController(text: widget.post?.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Set loading state using Riverpod
      ref.read(_loadingProvider.notifier).state = true;

      try {
        final post = Post(
          id: widget.post?.id,
          userId: widget.post?.userId ?? 1, // Default userId
          title: _titleController.text,
          body: _bodyController.text,
        );

        if (widget.post == null) {
          await ref.read(postsNotifierProvider.notifier).createPost(post);
        } else {
          await ref.read(postsNotifierProvider.notifier).updatePost(post);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) {
          // Reset loading state using Riverpod
          ref.read(_loadingProvider.notifier).state = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loading state from Riverpod
    final isLoading = ref.watch(_loadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Create Post' : 'Edit Post'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'Title',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'Body',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                        ),
                        style: const TextStyle(color: Colors.black),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a body';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  widget.post == null ? 'Create' : 'Update',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
