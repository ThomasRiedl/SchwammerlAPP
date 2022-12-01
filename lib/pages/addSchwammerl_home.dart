import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schwammerlapp/pages/addSchwammerl_add.dart';
import 'package:schwammerlapp/constraints.dart/textstyle.dart';
import 'package:schwammerlapp/pages/addSchwammerl_edit.dart';
import 'package:flutter/material.dart';

class AddSchwammerlPage extends StatefulWidget {
  const AddSchwammerlPage({Key? key}) : super(key: key);

  @override
  State<AddSchwammerlPage> createState() => _AddSchwammerlPageState();
}

class _AddSchwammerlPageState extends State<AddSchwammerlPage> {
  // Getting Student all Records
  final Stream<QuerySnapshot> carRecords =
      FirebaseFirestore.instance.collection('places').snapshots();
  // For Deleting Users
  CollectionReference delCars =
      FirebaseFirestore.instance.collection('places');
  Future<void> _delete(id) {
    return delCars
        .doc(id)
        .delete()
        .then((value) => print('Schwammerl Deleted'))
        .catchError((_) => print('Something Error In Deleted Schwammerl'));
  }

  Widget _title() {
    return const Text('Schwammerlplätze');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: carRecords,
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
            ),
            body: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    1: FixedColumnWidth(150),
                  },
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
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPage(
                                          docID: firebaseData[i]['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _delete(firebaseData[i]['id']);
                                    //print(firebaseData);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.orange,
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
