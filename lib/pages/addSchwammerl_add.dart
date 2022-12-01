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

  String imageUrl = '';

  //form key
  final _formkey = GlobalKey<FormState>();
  // text for textfield
  String name = '';
  String info = '';
  // textfield

  double long = 0;
  double lat = 0;

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
  Future<void> _registerSchwammerl() {
    return addSchwammerl
        .add({'name': name, 'info': info, 'coords' : GeoPoint(lat, long), 'image' : imageUrl})
        .then((value) => print('added Schwammerl'))
        .catchError((_) => print('Something Error In registering Schwammerl'));
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
                    onPressed: () async {

                      ImagePicker imagePicker = ImagePicker();

                      XFile? file =
                      await imagePicker.pickImage(source: ImageSource.camera);
                      print('${file?.path}');
                      //Import dart:core
                      String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                      /*Step 2: Upload to Firebase storage*/
                      //Install firebase_storage
                      //Import the library

                      //Get a reference to storage root
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages =
                      referenceRoot.child('images');

                      //Create a reference for the image to be stored
                      Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);

                      await referenceImageToUpload.putFile(File(file!.path));
                      imageUrl = await referenceImageToUpload.getDownloadURL();
                      print(imageUrl);
                    },
                    icon: Icon(Icons.camera_alt)),
                ElevatedButton(
                  onPressed: () async {
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
                  child: const Text('Platz speichern'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}