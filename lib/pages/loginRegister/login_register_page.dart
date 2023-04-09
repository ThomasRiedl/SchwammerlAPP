import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/firebase/auth.dart';
import 'package:schwammerlapp/main/main.dart';
import 'package:schwammerlapp/main/nav_bar_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final mainColor = const Color(0xFFf8cdd1);

  final _formkey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  CollectionReference addCar = FirebaseFirestore.instance.collection('users');

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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,0,0,16),
      child: Text(errorMessage == '' ? '' : 'Something went wrong $errorMessage'),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(isLogin ? 'Anmelden' : 'Registrieren',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;});},
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith(
                    (state) => mainColor)),
      child: Text(isLogin ? 'Zur Registrieren-Seite' : 'Zur Anmelde-Seite'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('SchwammerlApp'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(248, 205, 209, 1),
              Color.fromRGBO(45, 46, 55, 1),
            ],
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formkey,
            child: ListView(
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 15,
                      ),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: _controllerEmail,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                hintText: 'E-Mail',
                                hintStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.person, color: Colors.black),
                                border: InputBorder.none,
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(30).copyWith(
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0))),
                                contentPadding: EdgeInsets.all(26),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(30).copyWith(
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(30).copyWith(
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0)))),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 15,
                      ),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: _controllerPassword,
                            obscureText: !_passwordVisible,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                hintText: 'Passwort',
                                hintStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.lock, color: Colors.black),
                                border: InputBorder.none,
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(30).copyWith(
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0))),
                                contentPadding: EdgeInsets.all(26),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(30).copyWith(
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(30).copyWith(
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0)))),
                          ),
                          IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                            },
                          )
                        ],
                      ),
                    ),
                    _errorMessage(),
                    _submitButton(),
                    _loginOrRegisterButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Scaffold(
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
            SizedBox(height: 30,),
            _entryField('password', _controllerPassword),
          ],
        ),
      ),
    );
  }
}