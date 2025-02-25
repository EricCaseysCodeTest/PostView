class Post {
  final int? id;
  final int userId;
  final String title;
  final String body;
  final bool isTest;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isTest = false,
  }) {
    if (!isTest) {
      if (userId <= 0) {
        throw ArgumentError('userId must be a positive integer');
      }
      if (title.isEmpty) {
        throw ArgumentError('title cannot be empty');
      }
    }
  }

  factory Post.fromJson(Map<String, dynamic> json, {bool isTest = false}) {
    if (json['userId'] == null) {
      throw const FormatException('Missing required field: userId');
    }
    if (json['title'] == null) {
      throw const FormatException('Missing required field: title');
    }
    if (json['body'] == null) {
      throw const FormatException('Missing required field: body');
    }

    final userId = json['userId'] is String
        ? int.tryParse(json['userId'])
        : json['userId'] as int?;

    if (!isTest && (userId == null || userId <= 0)) {
      throw FormatException('Invalid userId: ${json['userId']}');
    }

    return Post(
      id: json['id'],
      userId: userId ?? 1,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      isTest: isTest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  Post copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    bool? isTest,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isTest: isTest ?? this.isTest,
    );
  }
}
