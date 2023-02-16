import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/pages/mapScene/mapScene_page.dart';
import 'package:schwammerlapp/pages/info/schwammerl_info_page.dart';
import 'package:schwammerlapp/pages/settings/settings_page.dart';

class NavBarPage extends StatefulWidget {
  NavBarPage({Key? key, this.initialPage, this.page}) : super(key: key);

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'MapScenePage';
  late Widget? _currentPage;
  var currentUser = FirebaseAuth.instance.currentUser?.uid;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
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
      body: IndexedStack(
        children: <Widget>[
          SchwammerlInfoPage(),
          MapScenePage(),
          SettingsPage(docID: currentUser.toString(),),
        ],
        index: currentIndex,
      ),
    );
  }
}
