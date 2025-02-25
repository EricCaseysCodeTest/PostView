// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postRepositoryHash() => r'8b77a458fb6ac997316fc1a3cbb8aee1688ec0dd';

/// See also [postRepository].
@ProviderFor(postRepository)
final postRepositoryProvider = AutoDisposeProvider<PostRepository>.internal(
  postRepository,
  name: r'postRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$postRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PostRepositoryRef = AutoDisposeProviderRef<PostRepository>;
String _$postCommentsHash() => r'5199967c4c5ba6dbd1d2829e54fd6ab2dcd53670';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [postComments].
@ProviderFor(postComments)
const postCommentsProvider = PostCommentsFamily();

/// See also [postComments].
class PostCommentsFamily extends Family<AsyncValue<List<Comment>>> {
  /// See also [postComments].
  const PostCommentsFamily();

  /// See also [postComments].
  PostCommentsProvider call(
    int postId,
  ) {
    return PostCommentsProvider(
      postId,
    );
  }

  @override
  PostCommentsProvider getProviderOverride(
    covariant PostCommentsProvider provider,
  ) {
    return call(
      provider.postId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postCommentsProvider';
}

/// See also [postComments].
class PostCommentsProvider extends AutoDisposeFutureProvider<List<Comment>> {
  /// See also [postComments].
  PostCommentsProvider(
    int postId,
  ) : this._internal(
          (ref) => postComments(
            ref as PostCommentsRef,
            postId,
          ),
          from: postCommentsProvider,
          name: r'postCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postCommentsHash,
          dependencies: PostCommentsFamily._dependencies,
          allTransitiveDependencies:
              PostCommentsFamily._allTransitiveDependencies,
          postId: postId,
        );

  PostCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final int postId;

  @override
  Override overrideWith(
    FutureOr<List<Comment>> Function(PostCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostCommentsProvider._internal(
        (ref) => create(ref as PostCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Comment>> createElement() {
    return _PostCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostCommentsRef on AutoDisposeFutureProviderRef<List<Comment>> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _PostCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Comment>>
    with PostCommentsRef {
  _PostCommentsProviderElement(super.provider);

  @override
  int get postId => (origin as PostCommentsProvider).postId;
}

String _$postsNotifierHash() => r'ded2501f96643f7d6f3a8deff47a49e431404c10';

/// See also [PostsNotifier].
@ProviderFor(PostsNotifier)
final postsNotifierProvider =
    AutoDisposeNotifierProvider<PostsNotifier, PostsState>.internal(
  PostsNotifier.new,
  name: r'postsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$postsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PostsNotifier = AutoDisposeNotifier<PostsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
