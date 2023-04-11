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
  List<bool> _isExpanded = List.generate(100, (_) => false);
  final mainColor = const Color(0xFFf8cdd1);
  final secondaryColor = const Color(0xFF2D2E37);

  Future<void> _deleteRoute(id) {
    return delRoutes
        .doc(id)
        .delete()
        .then((value) => print('Route Deleted'))
        .catchError((_) => print('Something Error In Deleted Toute'));
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
          final List firebaseData = [];
          snapshot.data?.docs.map((DocumentSnapshot documentSnapshot) {
            Map store = documentSnapshot.data() as Map<String, dynamic>;
            firebaseData.add(store);
            store['id'] = documentSnapshot.id;
          }).toList();
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
              child: ListView.builder(
                itemCount: firebaseData.length,
                itemBuilder: (context, index) {
                  return ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    },
                    children: [
                      ExpansionPanel(
                        backgroundColor: Colors.transparent,
                        isExpanded: _isExpanded[index],
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return Container(
                            child: ListTile(
                              title: Text(
                                firebaseData[index]['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RouteEditPage(
                                                docID: firebaseData[index]['id'],
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
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: mainColor,
                                                title: Text('Route ' +firebaseData[index]['name']+ ' löschen?',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text('Sind Sie sich sicher, dass Sie diese Route löschen möchten?',
                                                ),
                                                actions: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(16,0,16,0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: mainColor,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                              side: BorderSide(color: Colors.black,
                                                                  width: 3), // add this line
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Abrechen',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18.0,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _deleteRoute(firebaseData[index]['id']);
                                                            Navigator.of(context).pop();
                                                            var snackBarEmpty = SnackBar(
                                                              content: Text('Die Route wurde erfolgreich gelöscht'),
                                                            );
                                                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarEmpty);
                                                            Navigator.of(context).pop();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: mainColor,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                              side: BorderSide(color: Colors.black,
                                                                  width: 3), // add this line
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Löschen',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
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
                            ),
                          );
                        },
                          body: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                            child: Container(
                              height: firebaseData[index]['schwammerlNames'].length * 29.0,
                              child: ListView.builder(
                                itemCount: firebaseData[index]['schwammerlNames'].length,
                                itemBuilder: (BuildContext context, int i) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.arrow_right,
                                          color: Colors.black,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                            child: Text(
                                              firebaseData[index]['schwammerlNames'][i],
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                      ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: mainColor,
              foregroundColor: secondaryColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RouteAddPage(),
                    ));
              },
              child: const Icon(Icons.add, size: 40,),
            ),
          );
        });
  }
}