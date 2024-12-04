class Post {
  int userId;
  int id;
  String title;
  String? body;
  Post(this.userId, this.id, this.title, this.body);

  factory Post.fromJson(dynamic json) {
    return Post(json['userId'] as int, json['id'] as int,
        json['title'] as String, json['body'] as String?);
  }
}
