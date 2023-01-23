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
  int pageIndex = 0;

  var currentUser = FirebaseAuth.instance.currentUser?.uid;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: pageIndex);
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
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: tabs.values.toList(),
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        },
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
