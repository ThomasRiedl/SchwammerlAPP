import 'dart:io';

import 'package:schwammerlapp/constraints.dart/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPage extends StatefulWidget {

  const AddPage({Key? key}) : super(key: key);


  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  GlobalKey<FormState> key = GlobalKey();

  CollectionReference _reference =
  FirebaseFirestore.instance.collection('places');

  //form key
  final _formkey = GlobalKey<FormState>();

  // text for textfield
  String name = '';
  String info = '';

  String imageUrl = '';

  double long = 0;
  double lat = 0;
  bool isUploading = false;
  late Position position;

  final nameController = TextEditingController();
  final infoController = TextEditingController();

  @override
  void initState() {
    getLocation();

  }

  _clearText() {
    nameController.clear();
    infoController.clear();
  }

  //Registering Users
  CollectionReference addSchwammerl =
      FirebaseFirestore.instance.collection('places');
  Future<void>? _registerSchwammerl() {
    while(!isUploading)
      {
        return addSchwammerl
            .add({'name': name, 'info': info, 'coords' : GeoPoint(lat, long), 'image' : imageUrl})
            .then((value) => print('added Schwammerl'))
            .catchError((_) => print('Something Error In registering Schwammerl'));
      }
      return null;
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    long = position.longitude;
    lat = position.latitude;
  }

  @override
  void dispose() {
    nameController.dispose();
    infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schwammerlplätze'),
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          children: [
            CustomTextEditField(
              controller: nameController,
              labettxt: 'Name',
            ),
            CustomTextEditField(
              controller: infoController,
              labettxt: 'Info',
              valid: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: dispose,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                  ),
                  child: const Text('Löschen'),
                ),
                IconButton(
                    onPressed: () async{
                      PickedFile? pickedFile = await ImagePicker().getImage(
                      source: ImageSource.camera,
                      maxHeight: 1920,
                      maxWidth: 1080,
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

                        imageUrl = await (await uploadTask).ref.getDownloadURL();
                      } catch (error) {
                        setState(() => isUploading = false);
                      }
                      setState(() => isUploading = false);
                      }
                },
                  icon: Icon(Icons.camera_alt)),
                IconButton(
                    onPressed: () async {
                        PickedFile? pickedFile = await ImagePicker().getImage(
                        source: ImageSource.gallery,
                        maxWidth: 1800,
                        maxHeight: 1800,
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

                          imageUrl = await (await uploadTask).ref.getDownloadURL();

                        } catch (error) {
                          setState(() => isUploading = false);
                        }
                        setState(() => isUploading = false);
                      }
                      },
                    icon: Icon(Icons.folder_copy_rounded)),
                ElevatedButton.icon(

                  onPressed: isUploading ?
                     null :() {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        name = nameController.text;
                        info = infoController.text;
                        _registerSchwammerl();
                        _clearText();
                        Navigator.pop(context);
                      });
                    }
                  },

                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                  ),
                    icon: isUploading
                        ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ) : const Icon(Icons.cloud_upload),
                  label: const Text('Platz speichern'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
