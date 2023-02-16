// @dart=2.9

import 'package:schwammerlapp/main/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_add.dart';
import '../firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SchwammerlApp());
}

class SchwammerlApp extends StatelessWidget {
  const SchwammerlApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      //home: const WidgetTree(),
      home: const SchwammerlAddPage(),
    );
  }
}
