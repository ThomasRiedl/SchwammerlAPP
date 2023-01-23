import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schwammerlapp/auth.dart';
import 'package:schwammerlapp/pages/login_register_page.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({Key? key, required this.docID,}) : super(key: key);
  final String docID;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _formkey = GlobalKey<FormState>();

  String? errorMessage = '';

  String applicantName = '';
  String email = '';
  String password = '';
  String imageApplicant = '';

  String imageApplicantNew = '';
  String imageApplicantOld = '';
  String applicantNameOld = '';
  String emailOld = '';
  String passwordOld = '';

  int oldImageCounter = 1;
  int getDataCounter = 1;
  int countSecondsCounter = 1;

  bool isUploading = false;
  bool isLogin = false;
  bool _passwordVisible = false;
  bool _passwordVisibleDialog = false;
  bool emailTaken = false;
  bool canDelete = true;
  int _secondsLeft = 5;
  late Timer _timer;

  final TextEditingController _controllerEmailDialog = TextEditingController();
  final TextEditingController _controllerPasswordDialog = TextEditingController();

  static const snackBarCancel = SnackBar(
    content: Text('Änderungen verworfen'),
  );

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

  Future<void> _getOldUser(id, applicantName, email, password, imageApplicantNew) {
    return user
        .doc(id)
        .update({'applicantName': applicantName, 'email': email, 'password': password, 'imageApplicant': imageApplicantNew,
    })
        .then((value) => print("User not Updated"))
        .catchError((error) => print("Failed to update User: $error"));
  }

  Future<void> _updateUser(id, applicantName, imageApplicantNew) {
    return user
        .doc(id)
        .update({'applicantName': applicantName, 'email': email, 'password': password, 'imageApplicant': imageApplicantNew,
    })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update User: $error"));
  }

  Future<void> _updateImage(id, imageUrlNew) {
    return user
        .doc(id)
        .update({'imageApplicant': imageUrlNew,})
        .then((value) => print("User Image Updated"))
        .catchError((error) => print("Failed to update User Image: $error"));
  }


  _deleteImage()
  {
    future: FirebaseFirestore.instance
        .collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('cars')
        .doc(widget.docID)
        .get();

    imageApplicantNew = "";
    imageApplicant = "";
    _updateImage(widget.docID, imageApplicantNew);
    setState(() {

    });
  }

  Future<void> _deleteUser(id) {
    return user
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((_) => print('Something Error In Deleted User'));
  }

  changePasswordAndEmailOld() async{
    try{
      await FirebaseAuth.instance.currentUser!.updatePassword(passwordOld);
      await FirebaseAuth.instance.currentUser!.updateEmail(emailOld);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailOld, password: passwordOld);
    } catch(e) {
      print("Error in cancel: $e");
    }
  }

  changePasswordOldEmail() async{
    try{
      await FirebaseAuth.instance.currentUser!.updatePassword(password);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailOld, password: password);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
  }

  changeEmailAndPassword() async{
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

  Widget _pickImage()
  {
    if(imageApplicant == "" && imageApplicantNew == "" || isUploading)
    {
      return const Text("");
    }
    if(imageApplicant != "" && imageApplicantNew == "")
    {
      return Image.network(imageApplicant);
    }
    if(imageApplicantNew == "")
    {
      return const Text("");
    }
    if(imageApplicantNew != "")
    {
      imageApplicant = "";
      return Image.network(imageApplicantNew);
    }
    else
    {
      return const Text("");
    }
  }

  Widget _deleteImageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center ,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _deleteImage,
          child: const Text('Bild Entfernen'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.orange),
          ),
        ),

      ],
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
        applicantName = data!['applicantName'];
        email = data!['email'];
        password = data!['password'];
        imageApplicant = data!['imageApplicant'];
        applicantNameOld = applicantName;
        emailOld = email;
        passwordOld = password;
        if(oldImageCounter != 0)
        {
          imageApplicantOld = imageApplicant;
          oldImageCounter = oldImageCounter -1;
        }
        getDataCounter = getDataCounter-1;
      }
        return Scaffold(
          appBar: AppBar(
            title: const Text('CarLog'),
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
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:() {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            changePasswordAndEmailOld();
                            _getOldUser(widget.docID, applicantNameOld, emailOld, passwordOld, imageApplicantOld);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(snackBarCancel);
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.orange),
                      ),
                      child: const Text('Abrechen'),
                    ),IconButton(
                      onPressed: () async{
                        PickedFile? pickedFile = await ImagePicker().getImage(
                          source: ImageSource.camera,
                          maxWidth: 1000,
                          maxHeight: 1600,
                          imageQuality: 50,
                        );
                        if (pickedFile != null) {
                          File imageFileCamera = File(pickedFile.path);

                          String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();

                          Reference referenceRoot = FirebaseStorage.instance.ref();
                          Reference referenceDirImages =
                          referenceRoot.child('images');

                          Reference referenceImageToUpload =
                          referenceDirImages.child(uniqueFileName);

                          try {
                            setState(() => isUploading = true);
                            UploadTask uploadTask =  referenceImageToUpload.putFile(File(imageFileCamera!.path));

                            imageApplicantNew = await (await uploadTask).ref.getDownloadURL();
                          } catch (error) {
                            setState(() => isUploading = false);
                          }
                          setState(() => isUploading = false);
                        }
                      },
                      icon: Icon(Icons.camera_alt),
                      color: Colors.black,),
                    IconButton(
                      onPressed: () async {
                        PickedFile? pickedFile = await ImagePicker().getImage(
                          source: ImageSource.gallery,
                          maxWidth: 1000,
                          maxHeight: 1600,
                          imageQuality: 50,
                        );
                        if (pickedFile != null) {
                          File imageFileGallery = File(pickedFile.path);

                          String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();

                          Reference referenceRoot = FirebaseStorage.instance.ref();
                          Reference referenceDirImages =
                          referenceRoot.child('images');

                          Reference referenceImageToUpload =
                          referenceDirImages.child(uniqueFileName);

                          try {
                            setState(() => isUploading = true);
                            UploadTask uploadTask =  referenceImageToUpload.putFile(File(imageFileGallery!.path));

                            imageApplicantNew = await (await uploadTask).ref.getDownloadURL();

                          } catch (error) {
                            setState(() => isUploading = false);
                          }
                          setState(() => isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.folder_copy_rounded),
                      color: Colors.black,),
                    ElevatedButton.icon(
                      onPressed: isUploading ? null :() {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            if(imageApplicant == "")
                            {
                              imageApplicant = imageApplicantNew;
                            }
                            if(isLogin == true)
                            {
                              _updateEmailAndPassword();
                            }
                            if(applicantNameOld != applicantName || imageApplicantOld != imageApplicant)
                            {
                              _updateUser(widget.docID, applicantName, imageApplicant);
                            }
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.orange),
                      ), icon: isUploading ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ) : const Icon(Icons.cloud_upload),
                      label: const Text('Update'),
                    ),
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
                                  SizedBox(height: 10),
                                  _deleteImageButton(),
                                  SizedBox(height: 10),
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
