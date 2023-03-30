import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  CollectionReference updateRoute =
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes');

  Future<void> _updateRoute(id, name) {
    return updateRoute
        .doc(id)
        .update({
      'name': name,
    })
        .then((value) => print("Route Updated"))
        .catchError((error) => print("Failed to update Route: $error"));
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Routen'),
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
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.orange),
                        ),
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
                ],
              ),
            ),
          );
        });
  }
}
