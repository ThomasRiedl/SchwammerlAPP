import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schwammerlapp/constraints/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:substring_highlight/substring_highlight.dart';

class SchwammerlInfoPage extends StatefulWidget {
  const SchwammerlInfoPage({Key? key}) : super(key: key);

  @override
  State<SchwammerlInfoPage> createState() => _SchwammerlInfoPageState();
}

const MaterialColor primaryColor = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFFf8cdd1),
    100: Color(0xFFf8cdd1),
    200: Color(0xFFf8cdd1),
    300: Color(0xFFf8cdd1),
    400: Color(0xFFf8cdd1),
    500: Color(_blackPrimaryValue),
    600: Color(0xFFf8cdd1),
    700: Color(0xFFf8cdd1),
    800: Color(0xFFf8cdd1),
    900: Color(0xFFf8cdd1),
  },
);

const int _blackPrimaryValue = 0xFFf8cdd1;

class _SchwammerlInfoPageState extends State<SchwammerlInfoPage> {
  final Stream<QuerySnapshot> schwammerlRecords =
  FirebaseFirestore.instance.collection('schwammerl').snapshots();

  List<String> autoCompleteDataInfo = [""];

  final ref = FirebaseStorage.instance.ref().child('fliegenpilz');
  var url = "";
  TextEditingController nameController = TextEditingController();

  final mainColor = const Color(0xFFf8cdd1);

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
          firebaseData.sort((a, b) => a['name'].compareTo(b['name']));
          autoCompleteDataInfo.clear();
          for (int i = 0; i < firebaseData.length; i++) {
            String name = firebaseData[i]['name'].toString();
            autoCompleteDataInfo.add(name);
          }
          if (nameController.text.isNotEmpty) {
            int index = firebaseData.indexWhere((element) => element['name'] == nameController.text);

            if (index != -1) {
              Map<String, dynamic> element = firebaseData.removeAt(index);
              firebaseData.insert(0, element);
            }
          }
          return Scaffold(
            appBar: CustomAppBar(),
            body: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover
                )
              ),
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder(
                    //top: BorderSide(color: Colors.white, width: 3.0),
                    //bottom: BorderSide(color: Colors.white, width: 3.0),
                    //left: BorderSide(color: Colors.white, width: 3.0),
                    //right: BorderSide(color: Colors.white, width: 3.0),
                    horizontalInside: BorderSide(color: Colors.white, width: 3.0),
                    //verticalInside: BorderSide(color: Colors.white, width: 3.0),
                  ),
                  columnWidths: const <int, TableColumnWidth>{
                    1: FixedColumnWidth(150),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            color: mainColor,
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
                            color: mainColor,
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
                            color: mainColor,
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
                                  firebaseData[i]['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: SizedBox(
                              child: Center(
                                child: Text(
                                  firebaseData[i]['latName'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
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
                    ],
                  ],
                ),
              ),
            ),
          );
        }
      );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top,
      color: primaryColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(1);
}
