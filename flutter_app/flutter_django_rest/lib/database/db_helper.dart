import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/blog_model.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _database;
  static const int _databaseVersion =
      2; // Mettez à jour la version de la base de données

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'blog_database.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _migrateDB,
      onDowngrade:
          _migrateDBDown, // Vous pouvez ajuster cela en fonction de vos besoins
    );
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE blogs (
          localId INTEGER PRIMARY KEY,
          id INTEGER,
          title TEXT,
          content TEXT,
          createdAt TEXT,
          updatedAt TEXT,
          synced INTEGER DEFAULT 0
        )
      ''');
      print("Table 'blogs' created successfully");
    } catch (e) {
      print("Error creating table: $e");
    }
  }

  Future<void> _migrateDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      print(
          "Performing database migration from version $oldVersion to $newVersion");

      // Ajoutez la colonne localId à la table blogs
      await db.execute('ALTER TABLE blogs ADD COLUMN localId INTEGER');

      print("Database migration complete");
    }
  }

  Future<void> _migrateDBDown(
      Database db, int oldVersion, int newVersion) async {
    print(
        "Performing database downgrade from version $oldVersion to $newVersion");

    if (oldVersion >= 2 && newVersion < 2) {
      await db.execute(
          'CREATE TEMPORARY TABLE blogs_backup(localId, id, title, content,createdAt,updatedAt, synced)');
      await db.execute(
          'INSERT INTO blogs_backup SELECT localId, id, title, content,createdAt,updatedAt, synced FROM blogs');
      await db.execute('DROP TABLE blogs');
      await db.execute(
          'CREATE TABLE blogs (id INTEGER PRIMARY KEY, title TEXT, content TEXT,createdAt TEXT,updatedAt TEXT, synced INTEGER DEFAULT 0)');
      await db.execute(
          'INSERT INTO blogs SELECT id, title, content,createdAt,updatedAt, synced FROM blogs_backup');
      await db.execute('DROP TABLE blogs_backup');
    }

    print("Database downgrade complete");
  }

  Future<int> insertBlog(Blog blog) async {
    Database db = await instance.database;
    try {
      blog.createdAt = DateTime.now();
      blog.updatedAt = DateTime.now();
      int localId = await db.insert(
        'blogs',
        blog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Inserting blog: $blog with localId: $localId");

      if (blog.synced == 1) {
        // Synchronisation asynchrone avec le backend
        syncBlogWithBackend(blog).then((backendId) async {
          print("Synchronization complete");
          if (backendId != null) {
            await markBlogAsSynced(localId, backendId);
          }
        }).catchError((error) {
          print("Error syncing with backend: $error");
          // Traitez les erreurs de synchronisation ici
        });
      }

      return localId;
    } catch (e) {
      print("Error inserting blog achille: $e");
      return -1; // or another error code
    }
  }

  Future<List<Blog>> getAllBlogs() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('blogs');
    return List.generate(maps.length, (index) {
      return Blog.fromMap(maps[index]);
    });
  }

  Future<int> updateBlog(Blog blog) async {
    Database db = await instance.database;
    blog.updatedAt = DateTime.now();
    int result = await db.update('blogs', blog.toMap(),
        where: 'localId = ?', whereArgs: [blog.localId]);
    if (blog.synced == 1) {
      await syncBlogWithBackend(blog);
    }
    return result;
  }

  Future<int> deleteBlog(int localId) async {
    Database db = await instance.database;
    int result =
        await db.delete('blogs', where: 'localId = ?', whereArgs: [localId]);

    return result;
  }

// synchronise tous les blogs non synchronisés
//localement avec le backend Django
  static Future<void> syncLocalBlogs() async {
    // Récupère la liste des blogs non synchronisés depuis la base de données locale
    List<Blog> unsyncedBlogs = await instance.getUnsyncedBlogs();
    print("Voir le donnee ne sont pas synchronise ${unsyncedBlogs}");

    // Synchronisation uniquement pour les blogs non synchronisés
    for (var blog in unsyncedBlogs) {
      print(
          "Blog localId: ${blog.localId}, title: ${blog.title}, content: ${blog.content}");

      // Synchronise le blog avec le backend et récupère l'ID du backend
      int? backendId = await syncBlogWithBackend(blog);

      // Si la synchronisation avec le backend est réussie
      if (backendId != null) {
        // Marque le blog comme synchronisé localement et sur le backend
        await markBlogAsSynced(blog.localId!, backendId);
        // Marque le blog comme synchronisé uniquement dans la base de données locale
        await markBlogAsSyncedInDatabase(blog.localId!);
      }
    }
  }

  Future<List<Blog>> getUnsyncedBlogs() async {
    // Obtient une référence à la base de données locale
    Database db = await DBHelper.instance.database;

    // Effectue une requête SQL sur la table 'blogs' pour récupérer les blogs non synchronisés
    List<Map<String, dynamic>> maps =
        await db.query('blogs', where: 'synced = ?', whereArgs: [0]);

    // Affiche le nombre de blogs non synchronisés dans la console
    print("Nombre de blogs non synchronisés : ${maps.length}");

    // Convertit la liste de résultats en une liste d'objets Blog
    return List.generate(maps.length, (index) {
      return Blog.fromMap(maps[index]);
    });
  }

  Future<void> updateBackendIds(List<Blog> unsyncedBlogs) async {
    // Mettez à jour le backend_id pour chaque blog dans votre base de données Flutter
    for (var blog in unsyncedBlogs) {
      await updateBlogBackendId(blog);
    }
  }

  Future<void> updateBlogBackendId(Blog blog) async {
    try {
      // Obtient une référence à la base de données locale
      Database db = await DBHelper.instance.database;

      // Met à jour la table 'blogs' en définissant 'backendId' sur blog.localId et 'synced' sur 1
      await db.update(
        'blogs',
        {'backendId': blog.localId, 'synced': 1},
        where: 'localId = ?', // Condition de mise à jour
        whereArgs: [blog.localId], // Valeur de la condition
      );
    } catch (e) {
      print('Error updating blog backendId: $e');
      // Gérez l'erreur selon vos besoins
    }
  }

  static Future<int?> syncBlogWithBackend(Blog blog) async {
    try {
      final response = await http.post(
        Uri.parse('https://trustmytask.com/apis/blogs/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': blog.localId,
          'title': blog.title,
          'content': blog.content,
          // 'created':
          //     blog.createdAt!.toIso8601String(), // Envoyer la date au backend
          // Autres champs selon votre modèle Django
        }),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        int backendId = responseData['id'];
        await markBlogAsSynced(blog.localId!, backendId);
        await markBlogAsSyncedInDatabase(
            blog.localId!); // Mettez à jour synced = 1 dans la base de données

        print("Sychronisation bien");
        print("voir id backend $backendId");
        print("voir id local ${blog.localId!}");
        return backendId;
      } else {
        print("Error syncing with backend - ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error syncing with backend: $e");
      return null;
    }
  }

// mettre à jour l'état de synchronisation dans la base de données locale
//après une synchronisation réussie avec le backend
  static Future<void> markBlogAsSynced(int localId, int backendId) async {
    // Obtient une référence à la base de données locale
    Database db = await instance.database;

    // Met à jour la table 'blogs' en définissant 'synced' sur 1 et 'id' sur backendId
    // pour l'enregistrement correspondant à localId
    await db.update(
      'blogs',
      {'synced': 1, 'id': backendId},
      where: 'localId = ?', // Condition de mise à jour
      whereArgs: [localId], // Valeur de la condition
    );
  }

  // Fonction pour mettre à jour synced = 1 dans la base de données locale
  static Future<void> markBlogAsSyncedInDatabase(int localId) async {
    // Obtient une référence à la base de données locale
    Database db = await instance.database;

    // Met à jour la table 'blogs' en définissant 'synced' sur 1 pour l'enregistrement correspondant à localId
    await db.update(
      'blogs',
      {'synced': 1},
      where: 'localId = ?', // Condition de mise à jour
      whereArgs: [localId], // Valeur de la condition
    );
  }
}
