import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/nav_bar_page.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  CollectionReference addCar =
  FirebaseFirestore.instance.collection('users');

  var currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void>? _registerUser() {
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return addCar
        .doc(currentUserId.toString())
        .set({'email': _controllerEmail.text, 'password': _controllerPassword.text, 'userID': currentUserId.toString()})
        .then((value) => print('User Added'))
        .catchError((_) => print('Something Error In registering User'));
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NavBarPage(initialPage: 'MapScenePage'),
        ),
            (r) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }
  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
    _registerUser();
  }

  Widget _title() {
    return const Text('SchwammerlAPP');
  }

  Widget _entryField(
      String title,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Something went wrong $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
      isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,),
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;});},
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith(
                    (state) => Colors.orange)),
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
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
            _entryField('email', _controllerEmail),
            _entryField('password', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
