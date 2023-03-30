import 'package:schwammerlapp/firebase/auth.dart';
import 'package:schwammerlapp/pages/loginRegister/login_register_page.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/main/nav_bar_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return NavBarPage(initialPage: 'MapScenePage');
        } else {
          return const LoginPage();
        }
      },
    );
  }
}