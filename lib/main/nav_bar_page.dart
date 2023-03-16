import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/pages/mapScene/mapScene_page.dart';
import 'package:schwammerlapp/pages/info/schwammerl_info_page.dart';
import 'package:schwammerlapp/pages/route/route_home.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_home.dart';
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
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
              size: 28,
            ),
            label: '--',
            tooltip: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.gps_fixed,
              size: 28,
            ),
            label: '--',
            tooltip: 'Schwammerl',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_upward,
              size: 32,
            ),
            label: '--',
            tooltip: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.route,
              size: 28,
            ),
            label: '--',
            tooltip: 'Routen',
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
            tooltip: 'Einstellungen',
          ),
        ],
      ),
      body: IndexedStack(
        children: <Widget>[
          SchwammerlInfoPage(),
          SchwammerlHomePage(),
          MapScenePage(),
          RouteHomePage(),
          SettingsPage(docID: currentUser.toString(),),
        ],
        index: currentIndex,
      ),
    );
  }
}
