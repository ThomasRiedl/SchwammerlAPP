import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/auth.dart';
import 'package:flutter/material.dart';
import 'package:schwammerlapp/pages/mapScene.dart';
import 'package:schwammerlapp/pages/schwammerlInfo.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('SchwammerlAPP');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Widget _showSchwammerlButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShowSchwammerlPage()),
        );
      },
      child: const Text('Schwammerl Info'),
    );
  }

  Widget _startButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScene()),
        );
      },
      child: const Text('Map'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
            _showSchwammerlButton(context),
            _startButton(context),
          ],
        ),
      ),
    );
  }
}
