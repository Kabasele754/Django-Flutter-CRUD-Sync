import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/blog_model.dart';
import 'blog_add_edit.dart';
import 'blog_delete.dart';

class BlogEditor extends StatefulWidget {
  @override
  _BlogEditorState createState() => _BlogEditorState();
}

class _BlogEditorState extends State<BlogEditor> {
  List<Blog> blogs = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    List<Blog> fetchedBlogs = await DBHelper.instance.getAllBlogs();
    setState(() {
      blogs = fetchedBlogs;
    });
  }

  Future<void> deleteBlog(Blog blog) async {
    setState(() {
      blogs.remove(blog);
    });
  }

  Future<void> _showDeleteDialog(int localId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this blog post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await DBHelper.instance.deleteBlog(localId);
                fetchData();
                _showSuccessMessage('Blog post deleted successfully.');
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Blogs'),
        ),
        body: ListView.separated(
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.article),
              title: Text(blogs[index].title),
              subtitle: Row(children: [
                Text('${blogs[index].content}\n${blogs[index].createdAt}'),
                // Text(
                //   '${blogs[index].createdAt}',
                //   style: TextStyle(color: Colors.red),
                // )
              ]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons
                        .edit), // Icône d'édition (vous pouvez changer ceci)
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BlogAddEdit(blog: blogs[index])),
                      ).then((_) {
                        fetchData(); // Refresh the list after adding/editing a blog
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteDialog(blogs[index].localId!);
                    },
                  ),
                ],
              ),
              onTap: () {
                // Action à effectuer lors du clic sur le ListTile
                // Par exemple, ouvrir une vue détaillée
              },
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlogAddEdit()),
              ).then((_) {
                fetchData(); // Refresh the list after adding/editing a blog
              });
            },
            child: Icon(Icons.add),
          ),

          SizedBox(width: 16.0), // Ajoutez un espacement entre les deux boutons
          FloatingActionButton(
            onPressed: () async {
              // Afficher un indicateur de chargement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16.0),
                      Text('Synchronizing...'),
                    ],
                  ),
                ),
              );

              // Appel de la synchronisation
              await DBHelper.syncLocalBlogs();

              // Cacher l'indicateur de chargement
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              // Afficher un message de succès ou de gestion des erreurs
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Synchronization complete'),
                ),
              );
            },
            child: Icon(Icons.sync),
          ),
        ]));
  }
}
