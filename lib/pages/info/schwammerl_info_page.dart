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

class _SchwammerlInfoPageState extends State<SchwammerlInfoPage> {
  // Getting Student all Records
  final Stream<QuerySnapshot> schwammerlRecords =
  FirebaseFirestore.instance.collection('schwammerl').snapshots();

  List<String> autoCompleteDataInfo = [""];

  final ref = FirebaseStorage.instance.ref().child('fliegenpilz');
  var url = "";
  TextEditingController nameController = TextEditingController();

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
            appBar: AppBar(
              title: _title(),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Autocomplete(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return autoCompleteDataInfo;
                            } else {
                              return autoCompleteDataInfo.where((word) => word
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase()));
                            }
                          },
                          optionsViewBuilder:
                              (context, Function(String) onSelected, options) {
                            return Material(
                              elevation: 4,
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: SubstringHighlight(
                                      text: option.toString(),
                                      term: nameController.text,
                                      textStyleHighlight: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      onSelected(option.toString());
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) => Divider(),
                                itemCount: options.length,
                              ),
                            );
                          },
                          onSelected: (selectedString) {
                            FocusScope.of(context).unfocus();
                            print(selectedString);
                          },
                          fieldViewBuilder:
                              (context, controller, focusNode, onEditingComplete) {
                            nameController = controller;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                hintText: "Name des Schwammerls",
                                prefixIcon: Icon(Icons.search),
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          nameController.clear();
                        },
                      ),
                    ],
                  ),
                  Container(
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
                                        firebaseData[i]['latName'],
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
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      );
  }
}
