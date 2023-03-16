import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/constraints/textstyle.dart';
import 'package:schwammerlapp/pages/route/route_add.dart';
import 'package:schwammerlapp/pages/route/route_edit.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_edit.dart';
import 'package:flutter/material.dart';

class RouteHomePage extends StatefulWidget {
  const RouteHomePage({Key? key}) : super(key: key);

  @override
  State<RouteHomePage> createState() => _RouteHomePageState();
}

class _RouteHomePageState extends State<RouteHomePage> {

  final Stream<QuerySnapshot> routeRecords =
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes').snapshots();
  CollectionReference delRoutes =
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes');

  Future<void> _deleteRoute(id) {
    return delRoutes
        .doc(id)
        .delete()
        .then((value) => print('Route Deleted'))
        .catchError((_) => print('Something Error In Deleted Toute'));
  }

  Widget _title() {
    return const Text('Routen');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: routeRecords,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in RoutePage');
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
                            builder: (context) => const RouteAddPage(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Route hinzufügen'),
                  ),
                ),
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(110),
                    1: FixedColumnWidth(160),
                    2: FixedColumnWidth(70),
                  },
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
                                'Schwammerl',
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
                                  firebaseData[i]['routeName'],
                                  style: txt2,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: SizedBox(
                              child: Center(
                                child: Text(
                                  firebaseData[i]['schwammerlNames'].toString(),
                                  style: txt2,
                                ),
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
                                          builder: (context) => RouteEditPage(
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
                                      _deleteRoute(firebaseData[i]['id']);
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