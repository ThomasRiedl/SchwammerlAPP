import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schwammerlapp/firebase/auth.dart';
import 'package:schwammerlapp/pages/loginRegister/login_register_page.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({Key? key, required this.docID,}) : super(key: key);
  final String docID;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _formkey = GlobalKey<FormState>();

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
                              content: Stack(
                                children: <Widget>[
                                  Container(
                                    height: 340,
                                    width: 340,
                                    child: ListView(
                                      children: [
                                        const Text("Bitte melden Sie sich erneut an"),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _controllerEmailDialog,
                                          decoration: const InputDecoration(
                                            labelText: 'E-Mail',
                                            labelStyle: TextStyle(fontSize: 18),
                                            errorStyle: TextStyle(color: Colors.orange, fontSize: 15),
                                            border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _controllerPasswordDialog,
                                          obscureText: !_passwordVisibleDialog,
                                          decoration: InputDecoration(
                                            labelText: 'Passwort',
                                            labelStyle: TextStyle(fontSize: 18),
                                            errorStyle: TextStyle(color: Colors.orange, fontSize: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _passwordVisibleDialog ? Icons.visibility : Icons.visibility_off,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _passwordVisibleDialog = !_passwordVisibleDialog;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(errorMessage == '' ? '' : 'Something went wrong $errorMessage'),
                                        SizedBox(height: 10),
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
                                            backgroundColor: Colors.orange,),
                                          child: const Text('Login'),
                                        ),
                                        SizedBox(height: 10),
                                        /*GestureDetector(
                                          child: const Center(
                                           child: Text(
                                            'Passwort vergessen?',
                                            style: TextStyle(
                                              decoration: TextDecoration.underline,
                                              color: Colors.orange,
                                              fontSize: 16,
                                            ),
                                          ),),
                                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => const ForgotPasswordPage(),
                                          )),
                                        ),*/
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
                  title: Text('Delete User'),
                  content: Text('Are you sure you want to delete this User?'),
                  actions: <Widget>[
                    SizedBox(
                      width: 200,
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
                      child: Text('Cancel'),
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
          appBar: AppBar(
            title: const Text('Schwammerl App'),
            backgroundColor: Colors.orange,
          ),
          body: Form(
            key: _formkey,
            child: ListView(
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
                        decoration: const InputDecoration(
                          labelText: 'E-Mail',
                          labelStyle: TextStyle(fontSize: 18),
                          errorStyle: TextStyle(color: Colors.orange, fontSize: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
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
                        decoration: InputDecoration(
                          labelText: 'Passwort',
                          labelStyle: TextStyle(fontSize: 18),
                          errorStyle: TextStyle(color: Colors.orange, fontSize: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
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
                          'Delete User',
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
                SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1,
                  child: Column(
                    children: [
                      SizedBox(
                          width: 294,
                          height: 392,
                          child: SingleChildScrollView(
                            child: Column(
                                children: <Widget>[
                                  _signOutButton(),
                                ]
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}