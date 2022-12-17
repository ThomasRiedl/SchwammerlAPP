import 'dart:io';
import 'package:schwammerlapp/constraints.dart/textfield.dart';
import 'package:schwammerlapp/constraints.dart/textfieldNoVal.dart';
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

  //form key
  final _formkey = GlobalKey<FormState>();

  // text for textfield
  String name = '';
  String info = '';
  String imageUrl = '';

  double long = 0;
  double lat = 0;
  late Position position;

  bool isUploading = false;

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
            .then((value) => print('added Schwammerl Place'))
            .catchError((_) => print('Something Error In registering Schwammerl'));
      }
      return null;
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    long = position.longitude;
    lat = position.latitude;
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
    imageUrl = "";
    setState(() {

    });
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
            CustomTextEditFieldNoVal(
              controller: infoController,
              labettxt: 'Info',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _clearText,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                  ),
                  child: const Text('Löschen'),
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

                          imageUrl = await (await uploadTask).ref.getDownloadURL();

                        } catch (error) {
                          setState(() => isUploading = false);
                        }
                        setState(() => isUploading = false);
                      }
                      },
                    icon: const Icon(Icons.folder_copy_rounded)),
                ElevatedButton.icon(
                  onPressed: isUploading ? null :() {
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
                  ), icon: isUploading ? Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(imageUrl == "")
                                    const Text(''),
                                  if(imageUrl != "")
                                    Image.network(imageUrl)
                                ],
                              ),
                            )
                          )
                        ],
                      )
                    ),
            SizedBox(height: 10),
            _deleteImageButton(),
          ]
        ),
      ),
    );
  }
}
