import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SchwammerlEditPage extends StatefulWidget {
  const SchwammerlEditPage({Key? key, required this.docID,}) : super(key: key);
  final String docID;
  @override
  State<SchwammerlEditPage> createState() => _SchwammerlEditPageState();
}

class _SchwammerlEditPageState extends State<SchwammerlEditPage> {

  final _formkey = GlobalKey<FormState>();

  double long = 0;
  double lat = 0;

  var imageUrl = '';
  String imageUrlNew = '';

  String imageUrlOld = '';
  String nameOld = '';
  String infoOld = '';

  int oldImageCounter = 1;

  bool isUploading = false;

  CollectionReference updateSchwammerl =
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');

  Future<void> _updateUser(id, name, info, imageUrlNew) {
    return updateSchwammerl
        .doc(id)
        .update({
          'name': name,
          'info': info,
          'image': imageUrlNew,
        })
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update Schwammerl: $error"));
  }

  Future<void> _updateImage(id, imageUrlNew) {
    return updateSchwammerl
        .doc(id)
        .update({
      'image': imageUrlNew,
    })
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update Schwammerl: $error"));
  }

  Widget _pickImage()
  {
      if(imageUrl == "" && imageUrlNew == "" || isUploading)
      {
        return const Text("");
      }
      if(imageUrl != "" && imageUrlNew == "")
      {
        return Image.network(imageUrl);
      }
      if(imageUrlNew == "")
      {
        return const Text("");
      }
      if(imageUrlNew != "")
      {
        imageUrl = "";
        return Image.network(imageUrlNew);
      }
      else
      {
        return const Text("");
      }
  }

  _deleteImage()
  {
    future: FirebaseFirestore.instance
        .collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations')
        .doc(widget.docID)
        .get();

      imageUrlNew = "";
      imageUrl = "";
      _updateImage(widget.docID, imageUrlNew);
      setState(() {

      });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations')
            .doc(widget.docID)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in HomePage');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.data?.data();
          var name = data!['name'];
          var info = data['info'];
          imageUrl = data['image'];
          nameOld = name;
          infoOld = info;
          if(oldImageCounter != 0)
          {
            imageUrlOld = imageUrl;
            oldImageCounter = oldImageCounter -1;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Schwammerl bearbeiten'),
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
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 15,
                        ),
                        child: TextFormField(
                          initialValue: name,
                          onChanged: (value) {
                            name = value;
                          },
                          decoration: InputDecoration(
                              hintText: "Name des Schwammerl",
                              prefixIcon: Padding(
                                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                child: Image.asset('assets/images/mushroom_pink.png',
                                  width: 8,
                                  height: 8,
                                ),
                              ),
                              hintStyle: TextStyle(color: Colors.black),
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
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please Fill Name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 15,
                        ),
                        child: TextFormField(
                          initialValue: info,
                          onChanged: (value) {
                            info = value;
                          },
                          decoration: InputDecoration(
                              hintText: "Info",
                              prefixIcon: Icon(Icons.search, color: Colors.black, size: 28,),
                              hintStyle: TextStyle(color: Colors.black),
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:() {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  _updateUser(widget.docID, nameOld, infoOld, imageUrlOld);
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: const Text('Abrechen'),
                          ),
                          IconButton(
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

                                    imageUrlNew = await (await uploadTask).ref.getDownloadURL();
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

                                    imageUrlNew = await (await uploadTask).ref.getDownloadURL();

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
                                if(imageUrlNew != "")
                                {
                                  imageUrl = imageUrlNew;
                                }
                                _updateUser(widget.docID, name, info, imageUrl);
                              Navigator.pop(context);
                              });
                              }
                            },
                            icon: isUploading ? Container(
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
                      Align(
                        alignment: AlignmentDirectional(0, 1),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(imageUrlNew != "")
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: Image.network(
                                                  imageUrl,
                                                ).image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                  width: 190.0,
                                  height: 190.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.network(
                                        imageUrlNew,
                                      ).image,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: CircleAvatar(
                                              child: IconButton(
                                                onPressed: () {
                                                  _deleteImage();
                                                  setState(() {

                                                  });
                                                },
                                                highlightColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                icon: Icon(Icons.cancel_outlined),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ),
                                ),
                              if(imageUrl == "" && imageUrlNew == "")
                                Container(
                                  width: 190.0,
                                  height: 190.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.asset('assets/images/mushroom_pink_full.png',).image,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: CircleAvatar(
                                              child: IconButton(
                                                onPressed: () {
                                                  _deleteImage();
                                                  setState(() {

                                                  });
                                                },
                                                highlightColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                icon: Icon(Icons.cancel_outlined),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                               if(imageUrl != "" && imageUrlNew == "")
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: Image.network(
                                                  imageUrl,
                                                ).image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 190.0,
                                    height: 190.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: Image.network(
                                          imageUrl,
                                        ).image,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: CircleAvatar(
                                                child: IconButton(
                                                  onPressed: () {
                                                    _deleteImage();
                                                    setState(() {

                                                    });
                                                  },
                                                  highlightColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                  icon: Icon(Icons.cancel_outlined),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
