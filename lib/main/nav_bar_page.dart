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
  static const navBarColor = const Color(0xFF2d2e37);
  static const iconColor = const Color(0xFFf8cdd1);

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
        backgroundColor: navBarColor,
        selectedItemColor: iconColor,
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              child: Icon(
                Icons.info_outline,
                size: 28,
              ),
            ),
            activeIcon: Icon(
                Icons.info,
                size: 28
            ),
            label: 'Info',
            tooltip: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/mushroom_white.png',
              width: 32,
              height: 32,
            ),
            activeIcon: Image.asset('assets/images/mushroom_pink.png',
              width: 32,
              height: 32,
            ),
            label: 'Schwammerl',
            tooltip: 'Schwammerl',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.explore_outlined,
              size: 32,
            ),
            activeIcon: Icon(
              Icons.explore,
              size: 32
            ),
            label: 'Karte',
            tooltip: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.route,
              size: 28,
            ),
            label: 'Routen',
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
            label: 'Einstellungen',
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
