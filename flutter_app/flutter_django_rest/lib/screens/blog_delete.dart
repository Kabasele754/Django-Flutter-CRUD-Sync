import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/blog_model.dart';

class BlogDelete extends StatelessWidget {
  final Blog blog;

  BlogDelete({Key? key, required this.blog, required Null Function() onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmation'),
      content: Text('Are you sure you want to delete this blog?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await DBHelper.instance.deleteBlog(blog.localId!);
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
