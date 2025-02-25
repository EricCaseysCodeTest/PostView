class Comment {
  final int? id;
  final int postId;
  final String name;
  final String email;
  final String body;
  final bool isTest;

  Comment({
    this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
    this.isTest = false,
  }) {
    if (!isTest) {
      if (postId <= 0) {
        throw ArgumentError('postId must be a positive integer');
      }
      if (name.isEmpty) {
        throw ArgumentError('name cannot be empty');
      }
      if (email.isEmpty) {
        throw ArgumentError('email cannot be empty');
      }
    }
  }

  factory Comment.fromJson(Map<String, dynamic> json, {bool isTest = false}) {
    if (json['postId'] == null) {
      throw const FormatException('Missing required field: postId');
    }
    if (json['name'] == null) {
      throw const FormatException('Missing required field: name');
    }
    if (json['email'] == null) {
      throw const FormatException('Missing required field: email');
    }
    if (json['body'] == null) {
      throw const FormatException('Missing required field: body');
    }

    final postId = json['postId'] is String
        ? int.tryParse(json['postId'])
        : json['postId'] as int?;

    if (!isTest && (postId == null || postId <= 0)) {
      throw FormatException('Invalid postId: ${json['postId']}');
    }

    final email = (json['email'] as String?) ?? '';

    return Comment(
      id: json['id'],
      postId: postId ?? 1,
      name: (json['name'] as String?) ?? '',
      email: email,
      body: (json['body'] as String?) ?? '',
      isTest: isTest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'name': name,
      'email': email,
      'body': body,
    };
  }

  Comment copyWith({
    int? id,
    int? postId,
    String? name,
    String? email,
    String? body,
    bool? isTest,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      name: name ?? this.name,
      email: email ?? this.email,
      body: body ?? this.body,
      isTest: isTest ?? this.isTest,
    );
  }
}
