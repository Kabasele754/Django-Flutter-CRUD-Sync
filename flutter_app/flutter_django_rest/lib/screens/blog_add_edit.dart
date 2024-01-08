import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/blog_model.dart';

class BlogAddEdit extends StatefulWidget {
  final Blog? blog;

  BlogAddEdit({Key? key, this.blog}) : super(key: key);

  @override
  _BlogAddEditState createState() => _BlogAddEditState();
}

class _BlogAddEditState extends State<BlogAddEdit> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.blog?.title ?? '');
    contentController = TextEditingController(text: widget.blog?.content ?? '');
  }

  List<Blog> blogs = [];

  Future<void> fetchData() async {
    List<Blog> fetchedBlogs = await DBHelper.instance.getAllBlogs();
    setState(() {
      blogs = fetchedBlogs;
    });
  }

  Future<void> _saveBlog() async {
    final title = titleController.text;
    final content = contentController.text;

    // Vérifiez si les champs de titre et de contenu ne sont pas vides
    if (title.isEmpty || content.isEmpty) {
      // Affichez une alerte ou un SnackBar indiquant que les champs sont obligatoires
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Title and content are required.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final newBlog = Blog(
      title: title,
      content: content,
      synced: 0,
    );

    if (widget.blog == null) {
      // Ajouter un nouveau blog
      await DBHelper.instance.insertBlog(newBlog);
    } else {
      // Mettre à jour le blog existant
      final updatedBlog = widget.blog!.copyWith(
        title: title,
        content: content,
      );
      await DBHelper.instance.updateBlog(updatedBlog);
    }

    // Afficher un SnackBar pour indiquer que l'opération a réussi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.blog == null ? 'Blog added' : 'Blog updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog == null ? 'Add Blog' : 'Edit Blog'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _saveBlog();
                Navigator.pop(context); // Close the add/edit screen
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
