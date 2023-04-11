import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schwammerlapp/firebase/auth.dart';
import 'package:schwammerlapp/main/main.dart';
import 'package:schwammerlapp/pages/loginRegister/login_register_page.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({Key? key, required this.docID,}) : super(key: key);
  final String docID;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _formkey = GlobalKey<FormState>();

  final mainColor = const Color(0xFFf8cdd1);
  final secondaryColor = const Color(0xFF2D2E37);

  String? errorMessage = '';

  String email = '';
  String password = '';
  String emailOld = '';
  String passwordOld = '';

  int getDataCounter = 1;
  int countSecondsCounter = 1;

  bool isLogin = false;
  bool _passwordVisible = false;
  bool _passwordVisibleDialog = false;

  bool emailTaken = false;
  bool canDelete = true;
  int _secondsLeft = 5;
  late Timer _timer;

  final TextEditingController _controllerEmailDialog = TextEditingController();
  final TextEditingController _controllerPasswordDialog = TextEditingController();

  static const snackBarError = SnackBar(
    content: Text("Beim Ändern der Benutzerdaten ist ein Fehler aufgetreten"),
  );

  static const snackBarUpdate = SnackBar(
    content: Text('Benutzerdaten erfolgreich gespeichert'),
  );

  static const snackBarEmailTaken = SnackBar(
    content: Text('Die gewünschte Email wird bereits verwendet'),
  );

  CollectionReference user = FirebaseFirestore.instance.collection('users');

  Future<void> _updateUserPassword(id, password) {
    return user
        .doc(id)
        .update({'password': password,
    })
        .then((value) => print("User Passwort Updated"))
        .catchError((error) => print("Failed to update Email: $error"));
  }

  Future<void> _updateUserEmail(id, email) {
    return user
        .doc(id)
        .update({'email': email,
    })
        .then((value) => print("User Email Updated"))
        .catchError((error) => print("Failed to update Password: $error"));
  }

  Future<void> _deleteUser(id) {
    return user
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((_) => print('Something Error In Deleted User'));
  }

  void changePasswordAndEmailOld() async{
    try{
      await FirebaseAuth.instance.currentUser!.updatePassword(passwordOld);
      await FirebaseAuth.instance.currentUser!.updateEmail(emailOld);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailOld, password: passwordOld);
    } catch(e) {
      print("Error in cancel: $e");
    }
  }

  void changePasswordOldEmail() async{
    try{
      await FirebaseAuth.instance.currentUser!.updatePassword(password);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailOld, password: password);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
  }

  void changeEmailAndPassword() async{
    try{
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      await FirebaseAuth.instance.currentUser!.updatePassword(password);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      } catch(e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
  }

  _clearText() {
    _controllerEmailDialog.clear();
    _controllerPasswordDialog.clear();
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  _showDialogLogin(_) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          SingleChildScrollView(
                            child: AlertDialog(
                              backgroundColor: mainColor,
                              content: Stack(
                                children: <Widget>[
                                  Container(
                                    height: 265,
                                    width: 340,
                                    child: ListView(
                                      children: [
                                        const Text("Bitte melden Sie sich erneut an", style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _controllerEmailDialog,
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
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _controllerPasswordDialog,
                                          obscureText: !_passwordVisibleDialog,
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
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              await Auth().signInWithEmailAndPassword(
                                                email: _controllerEmailDialog.text,
                                                password: _controllerPasswordDialog.text,
                                              );
                                              isLogin = true;
                                              Navigator.pop(context);
                                            } on FirebaseAuthException catch (e) {
                                              setState(() {
                                                errorMessage = e.message;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: mainColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              side: BorderSide(color: Colors.black,
                                              width: 3), // add this line
                                            ),
                                          ),
                                          child: const Text('Anmelden',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    ).then((result) {
      setState(() {
        _clearText();
      });
      if(isLogin == true)
      {
        Future.delayed(const Duration(seconds: 60)).then((_) {
          setState(() {
            isLogin = false;
          });
        });
      }
    });
  }

  _showDialogDeleteUser(_) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                if(countSecondsCounter == 1)
                {
                  countSecondsCounter--;
                  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                    setState(() {
                      if (_secondsLeft > 0) {
                        _secondsLeft--;
                      } else {
                        _timer.cancel();
                      }
                    });
                  });
                }
                return AlertDialog(
                  backgroundColor: mainColor,
                  title: Text('Benutzer löschen'),
                  content: Text('Sind Sie sich sicher, dass Sie diesen Benutzer löschen möchten?'),
                  actions: <Widget>[
                    SizedBox(
                      width: 190,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: _secondsLeft == 0 ?
                            () async {
                        FirebaseAuth.instance.currentUser!.delete();
                        _deleteUser(widget.docID);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ));
                        } : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          )),
                          elevation: MaterialStateProperty.all(4.0),
                        ),
                        child: Row(children: <Widget>[Text("Delete " + (_secondsLeft == 0 ? "" : "($_secondsLeft)"))]),

                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.black,
                              width: 3), // add this line
                        ),
                      ),
                      child: Text('Abrechen'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
          );
        }
    ).then((result) {
      countSecondsCounter++;
      _secondsLeft = 5;
    });
  }

  _updateEmailAndPassword()
  {
    FirebaseFirestore.instance.collection('users')
        .where("email", isEqualTo: email)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
          if(emailOld != email)
          {
            ScaffoldMessenger.of(context).showSnackBar(snackBarEmailTaken);
          }
          else if (emailOld == email)
          {
            ScaffoldMessenger.of(context).showSnackBar(snackBarUpdate);
          }
          changePasswordOldEmail();
          _updateUserPassword(widget.docID, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBarUpdate);
        changeEmailAndPassword();
        _updateUserEmail(widget.docID, email);
        _updateUserPassword(widget.docID, password);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docID)
        .get(),
      builder: (context, snapshot) {
      if(getDataCounter == 1)
      {
        if (snapshot.hasError) {
          print('Something Wrong in SettingsPage');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var data = snapshot.data?.data();
        email = data!['email'];
        password = data!['password'];
        emailOld = email;
        passwordOld = password;
        getDataCounter = getDataCounter-1;
      }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Einstellungen'),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
                              enabled: isLogin,
                              initialValue: email,
                              onChanged: (value) {
                                email = value;
                              },
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
                            isLogin ? Container() : IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                WidgetsBinding.instance.addPostFrameCallback(_showDialogLogin);
                              },
                            )
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
                              enabled: isLogin,
                              initialValue: password,
                              obscureText: !_passwordVisible,
                              onChanged: (value) {
                                password = value;
                              },
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
                              icon: Icon(isLogin ? _passwordVisible ? Icons.visibility : Icons.visibility_off : Icons.edit,
                              ),
                              onPressed: () {
                                if(isLogin == true)
                                {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                }
                                else if(isLogin == false)
                                {
                                  WidgetsBinding.instance.addPostFrameCallback(_showDialogLogin);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center ,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                if(isLogin == false)
                                {
                                  WidgetsBinding.instance.addPostFrameCallback(_showDialogLogin);
                                }
                                if(isLogin == true)
                                {
                                  WidgetsBinding.instance.addPostFrameCallback(_showDialogDeleteUser);
                                };
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)
                                )),
                                elevation: MaterialStateProperty.all(4.0),
                              ),
                              child: Text(
                                'Benutzer Löschen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 370, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center ,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        signOut();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const LoginPage(),
                                            ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text('Abmelden',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
                                    ),
                                  ),
                                ]
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}