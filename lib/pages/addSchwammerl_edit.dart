import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  //form key
  final _formkey = GlobalKey<FormState>();
  //Update User
  CollectionReference updateCar =
      FirebaseFirestore.instance.collection('places');
  Future<void> _updateUser(id, name, info) {
    return updateCar
        .doc(id)
        .update({
          'name': name,
          'info': info,
        })
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update Schwammerl: $error"));
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
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.orange),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              _updateUser(widget.docID, name, info);
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: const Text('Update'),
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
