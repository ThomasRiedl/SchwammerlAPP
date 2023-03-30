import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/constraints/textstyle.dart';
import 'package:schwammerlapp/pages/schwammerl/addInfo.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_add.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_edit.dart';
import 'package:flutter/material.dart';

class SchwammerlHomePage extends StatefulWidget {
  const SchwammerlHomePage({Key? key}) : super(key: key);

  @override
  State<SchwammerlHomePage> createState() => _SchwammerlHomePageState();
}

class _SchwammerlHomePageState extends State<SchwammerlHomePage> {

  final Stream<QuerySnapshot> schwammerlRecords =
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations').snapshots();
  CollectionReference delSchwammerl =
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');

  Future<void> _deleteSchwammerl(id) {
    return delSchwammerl
        .doc(id)
        .delete()
        .then((value) => print('Schwammerl Deleted'))
        .catchError((_) => print('Something Error In Deleted Schwammerl'));
  }

  Widget _title() {
    return const Text('Schwammerl');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: schwammerlRecords,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in HomePage');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Storing Data
          final List firebaseData = [];
          snapshot.data?.docs.map((DocumentSnapshot documentSnapshot) {
            Map store = documentSnapshot.data() as Map<String, dynamic>;
            firebaseData.add(store);
            store['id'] = documentSnapshot.id;
          }).toList();
          return Scaffold(
            appBar: AppBar(
              title: _title(),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SchwammerlAddPage(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Schwammerl hinzufügen'),
                  ),
                ),
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: [
                        TableCell(
                            child: Container(
                              color: Colors.orange,
                              child: Center(
                                child: Text(
                                  'Name',
                                  style: txt,
                                ),
                              ),
                            ),
                          ),
                        TableCell(
                            child: Container(
                              color: Colors.orange,
                              child: Center(
                                child: Text(
                                  'Info',
                                  style: txt,
                                ),
                              ),
                            ),
                          ),
                        TableCell(
                            child: Container(
                              color: Colors.orange,
                              child: Center(
                                child: Text(
                                  'Bild',
                                  style: txt,
                                ),
                              ),
                            ),
                          ),
                        TableCell(
                            child: Container(
                              color: Colors.orange,
                              child: Center(
                                child: Text(
                                  '',
                                  style: txt,
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                    for (var i = 0; i < firebaseData.length; i++) ...[
                    TableRow(
                      children: [
                        TableCell(
                            child: SizedBox(
                              child: Center(
                                child: Text(
                                  firebaseData[i]['name'],
                                  style: txt2,
                                ),
                              ),
                            ),
                        ),
                        TableCell(
                            child: SizedBox(
                              child: Center(
                                child: Text(
                                  firebaseData[i]['info'],
                                  style: txt2,
                                ),
                              ),
                            ),
                        ),
                        TableCell(
                            child: SizedBox(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if(firebaseData[i]['image'] == "")
                                    const Text(''),
                                  if(firebaseData[i]['image'] != "")
                                    firebaseData[i].containsKey('image') ? Image.network(
                                        '${firebaseData[i]['image']}') : Container(),
                                ],
                              ),
                            ),
                        ),
                        TableCell(
                            child: Row(
                            children: [
                              Flexible(
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SchwammerlEditPage(
                                          docID: firebaseData[i]['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: IconButton(
                                  onPressed: () {
                                    _deleteSchwammerl(firebaseData[i]['id']);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ], //this is loop
                ],
              ),
            ),
          ),
        );
      });
  }
}