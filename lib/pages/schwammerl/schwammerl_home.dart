import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/constraints/textstyle.dart';
import 'package:schwammerlapp/pages/schwammerl/addInfo.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_add.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_edit.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';

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

  final mainColor = const Color(0xFFf8cdd1);
  final secondaryColor = const Color(0xFF2D2E37);

  int loadCounter = 1;
  List<bool> _isExpanded = List.generate(100, (_) => false);

  Future<void> _deleteSchwammerl(id) {
    return delSchwammerl
        .doc(id)
        .delete()
        .then((value) => print('Schwammerl Deleted'))
        .catchError((_) => print('Something Error In Deleted Schwammerl'));
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
            body: Container(
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
                              subtitle: Text(
                                firebaseData[index]['info'],
                                style: const TextStyle(fontSize: 16),
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
                                              builder: (context) => SchwammerlEditPage(
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
                                                title: Text('Schwammerl ' +firebaseData[index]['name']+ ' löschen?',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text('Sind Sie sich sicher, dass Sie dieses Schwammerl löschen möchten?',
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
                                                            _deleteSchwammerl(firebaseData[index]['id']);
                                                            Navigator.of(context).pop();
                                                            var snackBarEmpty = SnackBar(
                                                              content: Text('Das Schwammerl wurde erfolgreich gelöscht'),
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
                          padding: const EdgeInsets.fromLTRB(8,0,8,0),
                          child: firebaseData[index]['image'] == "" ? CircleAvatar(
                            radius: 100,
                            backgroundImage: AssetImage('assets/images/mushroom.png'),
                            ) : GestureDetector(
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
                                          image: NetworkImage(firebaseData[index]['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(firebaseData[index]['image']),
                            ),
                          ),
                          ),
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
                      builder: (context) => const SchwammerlAddPage(),
                    ));
              },
              child: const Icon(Icons.add, size: 40,),
            ),
          );
          /*
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
        );*/
      });
  }
}