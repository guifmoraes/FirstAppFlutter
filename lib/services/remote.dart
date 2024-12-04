import 'package:first_app/models/posts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RemoteServices {
  Future<List<Post>?> getPosts() async {
    var client = http.Client();
    var uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    var response = await client.get(uri);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as List;
      List<Post> post =
          json.map((postJson) => Post.fromJson(postJson)).toList();
      return post;
    }
  }
}
