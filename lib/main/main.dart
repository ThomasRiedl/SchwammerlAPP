// @dart=2.9

import 'package:schwammerlapp/main/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_add.dart';
import '../firebase/firebase_options.dart';

const MaterialColor primaryColor = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFFf8cdd1),
    100: Color(0xFFf8cdd1),
    200: Color(0xFFf8cdd1),
    300: Color(0xFFf8cdd1),
    400: Color(0xFFf8cdd1),
    500: Color(_blackPrimaryValue),
    600: Color(0xFFf8cdd1),
    700: Color(0xFFf8cdd1),
    800: Color(0xFFf8cdd1),
    900: Color(0xFFf8cdd1),
  },
);

const int _blackPrimaryValue = 0xFFf8cdd1;

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
        primarySwatch: primaryColor,
      ),
      home: const WidgetTree(),
    );
  }
}
