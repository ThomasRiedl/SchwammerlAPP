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
import 'package:intl/intl.dart';

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

  DateTime now = DateTime.now();
  String date = '';

  double long = 0;
  double lat = 0;
  late Position position;

  bool isUploading = false;

  final infoController = TextEditingController();

  bool isLoading = false;

  List<String> autoCompleteDataInfo = [""];

  late TextEditingController nameController;

  CollectionReference addSchwammerl = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');
  CollectionReference addAll = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('all');

  final Stream<QuerySnapshot> infoRecords = FirebaseFirestore.instance.collection('schwammerl').snapshots();

  @override
  void initState() {
    getLocation();
    date = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);
  }

  _clearText() {
    nameController.clear();
    infoController.clear();
  }

  Future<void>? _addSchwammerl() {
    while(!isUploading)
    {
      return addSchwammerl
          .add({'name': name, 'info': info, 'coords' : GeoPoint(lat, long), 'image' : imageUrl, 'isSelected' : false, 'date' : date})
          .then((value) => print('Schwammerl Place added'))
          .catchError((_) => print('Something Error In registering Schwammerl'));
    }
    return null;
  }

  Future<void>? _addSchwammerlToAll() {
    while(!isUploading)
    {
      return addAll
          .add({'name': "Schwammerl: "+name, 'info': info, 'coords' : GeoPoint(lat, long), 'image' : imageUrl, 'isSelected' : false, 'date' : date})
          .then((value) => print('Schwammerl Place added'))
          .catchError((_) => print('Something Error In registering Schwammerl'));
    }
    return null;
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
          firebaseDataInfo.sort((a, b) => a['name'].compareTo(b['name']));
          autoCompleteDataInfo.clear();
          for (int i = 0; i < firebaseDataInfo.length; i++) {
            String name = firebaseDataInfo[i]['name'].toString();
            autoCompleteDataInfo.add(name);
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Schwammerl hinzufügen'),
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                            child: Autocomplete(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return autoCompleteDataInfo;
                                } else {
                                  return autoCompleteDataInfo.where((word) => word
                                      .toLowerCase()
                                      .contains(textEditingValue.text.toLowerCase()));
                                }
                              },
                              optionsViewBuilder:
                                  (context, Function(String) onSelected, options) {
                                return Material(
                                  color: Color.fromRGBO(231, 195, 198, 1.0),
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
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              nameController.clear();
                            },
                          ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: TextFormField(
                            controller: infoController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                hintText: 'Info',
                                hintStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.info_outline, color: Colors.black),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                              onPressed: () {
                                _clearText();
                                Navigator.pop(context);
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
                                    if(nameController.text == "")
                                    {
                                      var snackBarEmpty = SnackBar(
                                        content: Text('Bitte geben Sie einen Namen für das Schwammerl ein'),
                                      );
                                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(snackBarEmpty);
                                    }
                                    else {
                                      name = nameController.text;
                                      info = infoController.text;
                                      _addSchwammerl();
                                      _addSchwammerlToAll();
                                      _clearText();
                                      Navigator.pop(context);
                                    }
                                  });
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
                                label: const Text('Platz speichern'),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, 1),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(imageUrl == "")
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
                                                    imageUrl = "";
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
                                if(imageUrl != "")
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
                                                      imageUrl = "";
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
            ),
          );
        }
    );
  }
}