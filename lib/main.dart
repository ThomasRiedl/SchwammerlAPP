// @dart=2.9

import 'package:schwammerlapp/pages/mapScene.dart';
import 'package:schwammerlapp/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

/// This function initializes the Firebase app and runs the MyApp widget
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// This class is the root widget of the app and contains the MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  /// This method builds the MaterialApp widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const WidgetTree(),
    );
  }
}
