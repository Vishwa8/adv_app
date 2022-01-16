import 'package:flutter/material.dart';
import 'package:project/services/database.dart';
import 'package:provider/provider.dart';
import 'views/home.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (_) => FirestoreDatabase(),
      child: MaterialApp(
        title: 'ADV App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: HomePage(),
      ),
    );
  }
}
