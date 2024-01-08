import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'screens/blog.screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.initDatabase();
  runApp(MyApp());
}

class  MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Django CRUD Sync data ',
      debugShowCheckedModeBanner: false,
      home: BlogEditor(),
    );
  }
}
