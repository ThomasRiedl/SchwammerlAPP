import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RouteAddPage extends StatefulWidget {

  const RouteAddPage({Key? key}) : super(key: key);

  @override
  State<RouteAddPage> createState() => _RouteAddPageState();
}

class _RouteAddPageState extends State<RouteAddPage> {

  final _formkey = GlobalKey<FormState>();

  final currentUser = FirebaseAuth.instance.currentUser!.uid.toString();

  String name = '';
  String info = '';

  late TextEditingController searchController;

  CollectionReference addRoute = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes');
  final CollectionReference schwammerlCollection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');

  final Stream<QuerySnapshot> schwammerlRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations').snapshots();

  List<String> autoCompleteDataInfo = [""];

  bool isSelectedSchwammerl = false;

  String selectedDate = '';

  @override
  void initState() {

  }

  _clearText() {
    searchController.clear();
  }

  Future<void> _updateSchwammerl(id) {
    return schwammerlCollection
        .doc(id)
        .update({'isSelectedSchwammerl' : isSelectedSchwammerl, 'isSelected' : isSelectedSchwammerl})
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs dateRangePickerSelectionChangedArgs)
  {
    if (dateRangePickerSelectionChangedArgs.value.endDate != null) {
      DateTime startDate = dateRangePickerSelectionChangedArgs.value.startDate!;
      DateTime endDate = dateRangePickerSelectionChangedArgs.value.endDate!;

      String startDateString = '${startDate.day}-${_twoDigitString(startDate.month)}-${_twoDigitString(startDate.year)}';

      String endDateString = '${endDate.day}-${_twoDigitString(endDate.month)}-${_twoDigitString(endDate.year)}';

      setState(() {
        selectedDate = '$startDateString - $endDateString';
      });
    }
  }

  String _twoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }

  void _showCalender(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: SfDateRangePicker(
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onSelectionChanged,
              ),
            ),
          ],
        ),
      ),
    ).then((result) {
      setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
      });}
    );
  }

  _showNameDialog(_) {
    showBottomSheet(
        context: context,
        enableDrag: false,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(

              ),
            );
        }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_showNameDialog);
    return StreamBuilder<QuerySnapshot>(
        stream: schwammerlRecords,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in AddPage');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List firebaseDataSchwammerl = [];
          snapshot.data?.docs.map((DocumentSnapshot documentSnapshot) {
            Map store = documentSnapshot.data() as Map<String, dynamic>;
            firebaseDataSchwammerl.add(store);
            store['id'] = documentSnapshot.id;
          }).toList();
          autoCompleteDataInfo.clear();
          for (int i = 0; i < firebaseDataSchwammerl.length; i++) {
            String name = firebaseDataSchwammerl[i]['name'].toString();
            autoCompleteDataInfo.add(name);
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Schwammerlplätze'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Autocomplete(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return List<String>.from(autoCompleteDataInfo);
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
                                        term: searchController.text,
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
                              searchController = controller;
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
                          icon: Icon(Icons.calendar_month_rounded),
                          onPressed: () {
                            _showCalender(context);
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              for (var i = 0; i < firebaseDataSchwammerl.length; i++) {
                                if(searchController.text == firebaseDataSchwammerl[i]['name'])
                                {
                                  isSelectedSchwammerl = firebaseDataSchwammerl[i]['isSelected'];
                                  isSelectedSchwammerl = !isSelectedSchwammerl;
                                  _updateSchwammerl(firebaseDataSchwammerl[i]['id']);
                                  _clearText();
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.orange),
                            ),
                            child: const Text('Schwammerl hinzufügen'),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Text(selectedDate),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 400,
                          height: MediaQuery.of(context).size.height-300,
                          child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          for (var i = 0; i < firebaseDataSchwammerl.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 100,
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(0),
                                ), //BoxDecoration
                                child: CheckboxListTile(
                                  title: Text(firebaseDataSchwammerl[i]['name']),
                                  subtitle: Text(firebaseDataSchwammerl[i]['info'] == null ? '' : firebaseDataSchwammerl[i]['info']),
                                  secondary: Icon(Icons.travel_explore),
                                  autofocus: false,
                                  checkColor: Colors.white,
                                  selected: firebaseDataSchwammerl[i]['isSelected'],
                                  value: firebaseDataSchwammerl[i]['isSelected'],
                                  onChanged: (newValue) {
                                    setState(() {
                                      isSelectedSchwammerl = firebaseDataSchwammerl[i]['isSelected'];
                                      isSelectedSchwammerl = !isSelectedSchwammerl;
                                      _updateSchwammerl(firebaseDataSchwammerl[i]['id']);
                                    });
                                  },
                                ), //CheckboxListTile
                              ), //Container
                            ),
                          ],
                        ],//Padding
                          ), //C
                        ),// enter//SizedBox
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.orange),
                            ),
                            child: const Text('Route speichern'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
