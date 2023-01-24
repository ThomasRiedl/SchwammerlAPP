import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/pages/mapScene.dart';

import 'package:schwammerlapp/pages/schwammerlInfo.dart';import 'package:schwammerlapp/pages/settings_page.dart';

class NavBarPage extends StatefulWidget {
  NavBarPage({Key? key, this.initialPage, this.page}) : super(key: key);

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'MapScenePage';
  late Widget? _currentPage;
  var currentUser = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'SchwammerlInfoPage': SchwammerlInfoPage(),
      'MapScenePage': MapScene(),
      'SettingsPage': SettingsPage(docID: currentUser.toString(),),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);
    return Scaffold(
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) =>
            setState(() {
              _currentPage = null;
              _currentPageName = tabs.keys.toList()[i];
            }),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.info_outline,
              size: 32,
            ),
            label: '--',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_upward,
              size: 32,
            ),
            label: 'Home',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              size: 32,
            ),
            activeIcon: Icon(
              Icons.person_sharp,
              size: 32,
            ),
            label: '--',
            tooltip: '',
          ),
        ],
      ),
    );
  }
}
