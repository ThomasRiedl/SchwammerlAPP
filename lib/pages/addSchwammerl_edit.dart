import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//Bug Textfelder werden zurückgesetzt bei IconButtons wegen setState

class EditPage extends StatefulWidget {
  const EditPage({
    Key? key,
    required this.docID,
  }) : super(key: key);
  final String docID;
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

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
      FirebaseFirestore.instance.collection('places');
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

  Widget _deleteImageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center ,//Center Column contents vertically,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _deleteImage,
          child: const Text('Bild Entfernen'),
        ),
      ],
    );
  }

  _deleteImage()
  {
    future: FirebaseFirestore.instance
        .collection('places')
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
            .collection('places')
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
          //Getting Data From FireStore
          var data = snapshot.data?.data();
          var name = data!['name'];
          var info = data['info'];
          imageUrl = data['image'];

          if(oldImageCounter != 0)
          {
            imageUrlOld = imageUrl;
            oldImageCounter = oldImageCounter -1;
          }

          nameOld = name;
          infoOld = info;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Schwammerlplätze'),
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
                    child: TextFormField(
                      initialValue: name,
                      onChanged: (value) {
                        name = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontSize: 18),
                        errorStyle: TextStyle(color: Colors.orange, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Info',
                        labelStyle: TextStyle(fontSize: 18),
                        errorStyle: TextStyle(color: Colors.orange, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
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
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.orange),
                        ),
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
                            if(imageUrl == "")
                            {
                              imageUrl = imageUrlNew;
                            }
                            _updateUser(widget.docID, name, info, imageUrl);
                          Navigator.pop(context);
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
                                      _pickImage(),
                                    ]
                                ),
                              )
                          )
                        ],
                      ),
          ),
                  SizedBox(height: 10),
                  _deleteImageButton(),
                ],
              ),
            ),
          );
        });
  }
}
