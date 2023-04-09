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
  List<bool> _isExpanded = List.generate(110, (_) => false);

  final ref = FirebaseStorage.instance.ref().child('fliegenpilz');
  var url = "";
  TextEditingController nameController = TextEditingController();

  final mainColor = const Color(0xFFf8cdd1);
  final secondaryColor = const Color(0xFF2D2E37);

  displayImage() async {
    url = await ref.getDownloadURL();
    print(url);
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
              child: SafeArea(
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
                                title: SubstringHighlight(
                                  text: firebaseData[index]['name'],
                                  term: nameController.text,
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                  textStyleHighlight: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                subtitle: Text(
                                  firebaseData[index]['verzehrhinweis'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width: 200,
                                            height: 200,
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
                                    radius: 30,
                                    backgroundImage: NetworkImage(firebaseData[index]['image']),
                                  ),
                                ),
                              ),
                            );
                          },
                           body: Padding(
                             padding: const EdgeInsets.fromLTRB(8,0,8,16),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.start,
                               children: [
                                 Row(
                                   children: [
                                     const Text(
                                       'Beschreibung',
                                       style: TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ],
                                 ),
                                 Text(
                                   firebaseData[index]['sammeltipp'],
                                   style: const TextStyle(fontSize: 16),
                                 ),
                               ],
                             ),
                           ),
                         ),
                      ],
                    );
                  },
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
