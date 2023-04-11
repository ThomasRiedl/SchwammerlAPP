import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:substring_highlight/substring_highlight.dart';

class RouteEditPage extends StatefulWidget {
  const RouteEditPage({Key? key, required this.docID,}) : super(key: key);
  final String docID;
  @override
  State<RouteEditPage> createState() => _RouteEditPageState();
}

class _RouteEditPageState extends State<RouteEditPage> {

  final _formkey = GlobalKey<FormState>();

  String nameOld = '';

  bool isUploading = false;
  List firebaseDataSchwammerl = [];

  CollectionReference updateRoute =
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes');
  final CollectionReference schwammerlCollection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');

  List<String> autoCompleteDataInfo = [""];
  List<String> selectedSchwammerlName = [];
  List<GeoPoint> selectedSchwammerlCoords = [];
  bool isSelectedSchwammerl = false;

  Future<void> _updateRoute(id, name) {
    return updateRoute
        .doc(id)
        .update({
      'name': name,
    })
        .then((value) => print("Route Updated"))
        .catchError((error) => print("Failed to update Route: $error"));
  }

  Future<void> _updateSchwammerl(id) {
    return schwammerlCollection
        .doc(id)
        .update({'isSelectedSchwammerl' : isSelectedSchwammerl, 'isSelected' : isSelectedSchwammerl})
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid.toString())
        .collection('locations')
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        data['id'] = documentSnapshot.id;
        firebaseDataSchwammerl.add(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes')
            .doc(widget.docID)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in RoutePage');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.data?.data();
          var name = data!['name'];
          nameOld = name;
          print(firebaseDataSchwammerl.length);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Routen'),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SingleChildScrollView(
                              child: SizedBox(
                                width: 400,
                                height: MediaQuery.of(context).size.height-240,
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    for (var i = 0; i < firebaseDataSchwammerl.length; i++) ...[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 100,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black),
                                            borderRadius: BorderRadius.circular(0),
                                          ), //BoxDecoration
                                          child: CheckboxListTile(
                                            title: Text(firebaseDataSchwammerl[i]['name']),
                                            subtitle: Text(firebaseDataSchwammerl[i]['info'] == null ? '' : firebaseDataSchwammerl[i]['info']),
                                            secondary: Icon(Icons.travel_explore),
                                            autofocus: false,
                                            checkColor: Colors.white,
                                            selected: firebaseDataSchwammerl[i]['isSelected'],
                                            value: firebaseDataSchwammerl[i]['isSelected'],
                                            onChanged: (newValue) {
                                              setState(() {
                                                isSelectedSchwammerl = firebaseDataSchwammerl[i]['isSelected'];
                                                isSelectedSchwammerl = !isSelectedSchwammerl;
                                                _updateSchwammerl(firebaseDataSchwammerl[i]['id']);
                                              });
                                              selectedSchwammerlName.add(firebaseDataSchwammerl[i]['name']);
                                              if (firebaseDataSchwammerl[i]['isSelected'] == false) {
                                                GeoPoint currentCoords = firebaseDataSchwammerl[i]['coords'];
                                                selectedSchwammerlCoords = List<GeoPoint>.from(selectedSchwammerlCoords.where((gp) => gp != currentCoords));
                                                selectedSchwammerlCoords.add(currentCoords);
                                              }
                                            },
                                          ), //CheckboxListTile
                                        ), //Container
                                      ),
                                    ],
                                  ],//Padding
                                ), //C
                              ),
                            ),// enter//SizedBox
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),
                          child: TextFormField(
                            initialValue: name,
                            onChanged: (value) {
                              name = value;
                              print(name);
                            },
                            decoration: InputDecoration(
                                  hintText: 'Name der Route',
                                  hintStyle: TextStyle(color: Colors.black),
                                  prefixIcon: Icon(Icons.route, color: Colors.black),
                                  border: InputBorder.none,
                                  disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black, width: 3),
                                      borderRadius: BorderRadius.circular(30).copyWith(
                                          topRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(0))),
                                  contentPadding: EdgeInsets.fromLTRB(16, 20, 0, 20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed:() {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    _updateRoute(widget.docID, nameOld, );
                                    Navigator.pop(context);
                                  });
                                }
                              },
                              child: const Text('Abrechen'),
                            ),
                            ElevatedButton.icon(
                              onPressed: isUploading ? null :() {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    _updateRoute(widget.docID, name);
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
                      ],
                    )
                  ),
                ),
              ),
            ),
          );
        });
  }
}
