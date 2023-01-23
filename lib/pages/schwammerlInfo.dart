import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schwammerlapp/constraints.dart/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SchwammerlInfoPage extends StatefulWidget {
  const SchwammerlInfoPage({Key? key}) : super(key: key);

  @override
  State<SchwammerlInfoPage> createState() => _SchwammerlInfoPageState();
}

class _SchwammerlInfoPageState extends State<SchwammerlInfoPage> {
  // Getting Student all Records
  final Stream<QuerySnapshot> schwammerlRecords =
  FirebaseFirestore.instance.collection('schwammerl').snapshots();

  final ref = FirebaseStorage.instance.ref().child('fliegenpilz');
  var url = "";

  displayImage() async {
    url = await ref.getDownloadURL();
    print(url);
  }

  Widget _title() {
    return const Text('Schwammerl Info');
  }

  @override
  void initState() {
    displayImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: schwammerlRecords,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in Schwammerl Info Page');
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
                      ],
                    ),
                    for (var i = 0; i < firebaseData.length; i++) ...[
                      TableRow(
                        children: [
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
