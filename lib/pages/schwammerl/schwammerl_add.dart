import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/constraints/textfield.dart';
import 'package:schwammerlapp/constraints/textfieldNoVal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:substring_highlight/substring_highlight.dart';

class SchwammerlAddPage extends StatefulWidget {

  const SchwammerlAddPage({Key? key}) : super(key: key);

  @override
  State<SchwammerlAddPage> createState() => _SchwammerlAddPageState();
}

class _SchwammerlAddPageState extends State<SchwammerlAddPage> {

  final _formkey = GlobalKey<FormState>();

  final currentUser = FirebaseAuth.instance.currentUser!.uid.toString();

  String name = '';
  String info = '';
  String imageUrl = '';

  double long = 0;
  double lat = 0;
  late Position position;

  bool isUploading = false;

  final infoController = TextEditingController();

  bool isLoading = false;

  List<String> autoCompleteDataInfo = [""];

  late TextEditingController nameController;

  CollectionReference addSchwammerl = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');
  CollectionReference addSchwammerlInfo = FirebaseFirestore.instance.collection('schwammerl');

  final Stream<QuerySnapshot> infoRecords = FirebaseFirestore.instance.collection('schwammerl').snapshots();

  @override
  void initState() {
    getLocation();
  }

  _clearText() {
    //nameController.clear();
    //infoController.clear();
    nameInfoController.clear();
    latNameController.clear();
    sammeltippController.clear();
    verzehrhinweisController.clear();
  }

  Future<void>? _registerSchwammerl() {
    while(!isUploading)
    {
      return addSchwammerl
          .add({'name': name, 'info': info, 'coords' : GeoPoint(lat, long), 'image' : imageUrl})
          .then((value) => print('Schwammerl Place added'))
          .catchError((_) => print('Something Error In registering Schwammerl'));
    }
    return null;
  }

  String nameInfo = "";
  String latName = "";
  String sammeltipp = "";
  String verzehrhinweis = "";
  String image = "";
  final nameInfoController = TextEditingController();
  final latNameController = TextEditingController();
  final sammeltippController = TextEditingController();
  final verzehrhinweisController = TextEditingController();


  Future<void>? _registerSchwammerlInfo() {
    nameInfo = nameInfoController.text;
    latName = latNameController.text;
    sammeltipp = sammeltippController.text;
    verzehrhinweis = verzehrhinweisController.text;
    _clearText();
    return addSchwammerlInfo
          .add({'name': nameInfo, 'latName': latName, 'sammeltipp' : sammeltipp, 'verzehrhinweis' : verzehrhinweis, 'image' : image})
          .then((value) => print('Schwammerl Place added'))
          .catchError((_) => print('Something Error In registering Schwammerl'));
  }


  void getLocation() async {
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
    return StreamBuilder<QuerySnapshot>(
        stream: infoRecords,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        print('Something Wrong in AddPage');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      final List firebaseDataInfo = [];
      snapshot.data?.docs.map((DocumentSnapshot documentSnapshot) {
        Map store = documentSnapshot.data() as Map<String, dynamic>;
        firebaseDataInfo.add(store);
        store['id'] = documentSnapshot.id;
      }).toList();
      autoCompleteDataInfo.clear();
      for (int i = 0; i < firebaseDataInfo.length; i++) {
        String name = firebaseDataInfo[i]['name'].toString();
        autoCompleteDataInfo.add(name);
      }
      return Scaffold(
      appBar: AppBar(
        title: const Text('Schwammerlplätze'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /*
              Autocomplete(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  } else {
                    return autoCompleteDataInfo.where((word) => word
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  }
                },
                optionsViewBuilder:
                    (context, Function(String) onSelected, options) {
                  return Material(
                    elevation: 4,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: SubstringHighlight(
                            text: option.toString(),
                            term: nameController.text,
                            textStyleHighlight: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            onSelected(option.toString());
                          },
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: options.length,
                    ),
                  );
                },
                onSelected: (selectedString) {
                  FocusScope.of(context).unfocus();
                  print(selectedString);
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  nameController = controller;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      hintText: "Name des Schwammerls",
                      prefixIcon: Icon(Icons.search),
                    ),
                  );
                },
              ),
              CustomTextEditFieldNoVal(
                controller: infoController,
                labelttxt: 'Info',
              ),
               */
              CustomTextEditFieldNoVal(
                controller: nameInfoController,
                labelttxt: 'name',
              ),
              CustomTextEditFieldNoVal(
                controller: latNameController,
                labelttxt: 'latName',
              ),
              CustomTextEditFieldNoVal(
                controller: sammeltippController,
                labelttxt: 'sammeltipp',
              ),
              CustomTextEditFieldNoVal(
                controller: verzehrhinweisController,
                labelttxt: 'verzehrhinweis',
              ),
              /*
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
                      setState(() {
                        name = nameController.text;
                        info = infoController.text;
                        _registerSchwammerl();
                        _clearText();
                        Navigator.pop(context);
                      });
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
               */
              ElevatedButton(
                onPressed: _registerSchwammerlInfo,
                child: const Text('Info speichern 187'),
              ),
            ],
          ),
        ),
      ),
    );
  }
    );
}
}
