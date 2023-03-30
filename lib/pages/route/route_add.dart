import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:schwammerlapp/constraints/textfieldNoVal.dart';
import 'dart:async';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class RouteAddPage extends StatefulWidget {

  const RouteAddPage({Key? key}) : super(key: key);

  @override
  State<RouteAddPage> createState() => _RouteAddPageState();
}

class _RouteAddPageState extends State<RouteAddPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final currentUser = FirebaseAuth.instance.currentUser!.uid.toString();

  String name = '';
  String info = '';
  String routeName = '';
  late TextEditingController searchController;

  CollectionReference addRoute = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('routes');
  CollectionReference addAll = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('all');
  final CollectionReference schwammerlCollection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations');
  final Stream<QuerySnapshot> schwammerlRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid.toString()).collection('locations').snapshots();

  List<String> autoCompleteDataInfo = [""];
  List<String> selectedSchwammerlName = [];
  List<GeoPoint> selectedSchwammerlCoords = [];

  bool isSelectedSchwammerl = false;

  String startDateString = '';
  String endDateString = '';
  String selectedDate = '';

  int resetDate = 0;
  int checkboxCounter = 0;
  int loadCounter = 1;
  int selectCounter = 0;
  int getDataCounter = 1;
  bool loading = false;

  final routeNameController = TextEditingController();

  late DateTime? startDate;
  late DateTime? endDate;
  late DateTime? dateTime;
  @override
  void initState() {
  }

  _clearText() {
    searchController.clear();
  }

  Future<void> _updateSchwammerlSelectedFalse(id) {
    isSelectedSchwammerl = false;
    return schwammerlCollection
        .doc(id)
        .update({'isSelected' : isSelectedSchwammerl,})
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  Future<void> _updateSchwammerlSelectedTrue(id) {
    isSelectedSchwammerl = true;
    return schwammerlCollection
        .doc(id)
        .update({'isSelected' : isSelectedSchwammerl,})
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  Future<void> _updateSchwammerlSelectedTrueAll() {
    isSelectedSchwammerl = true;
    return schwammerlCollection
        .doc()
        .update({'isSelected' : isSelectedSchwammerl,})
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  Future<void> _updateSchwammerl(id) {
    return schwammerlCollection
        .doc(id)
        .update({'isSelectedSchwammerl' : isSelectedSchwammerl, 'isSelected' : isSelectedSchwammerl})
        .then((value) => print("Schwammerl Updated"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  Future<void> _addRoute() {
    return addRoute
        .add({'name' : routeName, 'schwammerlNames' : selectedSchwammerlName, 'schwammerlCoords' : selectedSchwammerlCoords})
        .then((value) => print("Route added"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  Future<void> _addRouteToAll() {
    return addAll
        .add({'name' : "Route: "+routeName, 'schwammerlNames' : selectedSchwammerlName, 'schwammerlCoords' : selectedSchwammerlCoords})
        .then((value) => print("Route added"))
        .catchError((error) => print("Failed to update selected Schwammerl: $error"));
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs dateRangePickerSelectionChangedArgs)
  {
    if (dateRangePickerSelectionChangedArgs.value.endDate != null) {
      startDate = dateRangePickerSelectionChangedArgs.value.startDate!;
      endDate = dateRangePickerSelectionChangedArgs.value.endDate!;
      selectCounter = 1;

      startDateString = '${startDate!.day}.${_twoDigitString(startDate!.month)}.${_twoDigitString(startDate!.year)}';
      endDateString = '${endDate!.day}.${_twoDigitString(endDate!.month)}.${_twoDigitString(endDate!.year)}';

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
        if(selectCounter == 1)
        {
          setState(() {
            loading = true;
            List firebaseDataSchwammerlDate = [];
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid.toString())
                .collection('locations')
                .snapshots()
                .listen((QuerySnapshot snapshot) {
              snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
                Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
                data!['id'] = documentSnapshot.id;
                firebaseDataSchwammerlDate.add(data);
              });
              for (int i = 0; i < firebaseDataSchwammerlDate.length; i++) {
                String pickedDate = firebaseDataSchwammerlDate[i]['date'].toString();
                String id = firebaseDataSchwammerlDate[i]['id'].toString();
                dateTime = DateTime.parse(pickedDate);

                if (dateTime!.isAfter(startDate!) && dateTime!.isBefore(endDate!)) {
                  _updateSchwammerlSelectedTrue(id);
                }
              }
              resetDate = 1;
            });
          });
        }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          if(resetDate == 1)
          {
            startDate = null;
            endDate = null;
            dateTime = null;
            resetDate--;
          }
          if(getDataCounter == 1)
          {
            selectCounter = selectCounter-1;
            getDataCounter = getDataCounter-1;
          }
          List firebaseDataSchwammerl = [];
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
          if(loadCounter == 1) {
            for (int i = 0; i < firebaseDataSchwammerl.length; i++) {
              _updateSchwammerlSelectedFalse(firebaseDataSchwammerl[i]['id']);
            }
            loadCounter = loadCounter-1;
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Schwammerlplätze'),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                SingleChildScrollView(
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
                            IconButton(
                              icon: Icon(Icons.cancel_outlined),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                searchController.clear();
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
                            SingleChildScrollView(
                              child: SizedBox(
                                width: 400,
                                height: MediaQuery.of(context).size.height-400,
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
                                          selectedSchwammerlName.add(firebaseDataSchwammerl[i]['name']);
                                          if (firebaseDataSchwammerl[i]['isSelected'] == false) {
                                            GeoPoint currentCoords = firebaseDataSchwammerl[i]['coords'];
                                            selectedSchwammerlCoords = List<GeoPoint>.from(selectedSchwammerlCoords.where((gp) => gp != currentCoords));
                                            selectedSchwammerlCoords.add(currentCoords);
                                          }
                                        },
                                      ), //CheckboxListTile
                                    ), //Container
                                  ),
                                ],
                              ],//Padding
                                ), //C
                              ),
                            ),// enter//SizedBox
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 220,
                                height: 100,
                                child: CustomTextEditFieldNoVal(
                                  controller: routeNameController,
                                  labelttxt: 'Name der Route',
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  routeName = routeNameController.text.toString();
                                  if(routeNameController.text == "")
                                  {
                                    var snackBarEmpty = SnackBar(
                                      content: Text('Bitte geben Sie einen Namen für die Route ein'),
                                    );
                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(snackBarEmpty);
                                  }
                                  else
                                  {
                                    _addRoute();
                                    _addRouteToAll();
                                    Navigator.pop(context);
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                                ),
                                child: const Text('Route speichern'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  loading = true;
                                  setState(() {
                                    List firebaseDataSchwammerl = [];
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
                                        .collection('locations')
                                        .snapshots()
                                        .listen((QuerySnapshot snapshot) {
                                      snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
                                        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
                                        data!['id'] = documentSnapshot.id;
                                        firebaseDataSchwammerl.add(data);
                                      });
                                      for (int i = 0; i < firebaseDataSchwammerl.length; i++) {
                                        String id = firebaseDataSchwammerl[i]['id'].toString();
                                        _updateSchwammerlSelectedFalse(id);
                                      }
                                    });
                                    loading = false;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                                ),
                                child: const Text('aktuelle Auswahl löschen'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  loading = true;
                                  setState(() {
                                    List firebaseDataSchwammerl = [];
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
                                        .collection('locations')
                                        .snapshots()
                                        .listen((QuerySnapshot snapshot) {
                                      snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
                                        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
                                        data!['id'] = documentSnapshot.id;
                                        firebaseDataSchwammerl.add(data);
                                      });
                                      for (int i = 0; i < firebaseDataSchwammerl.length; i++) {
                                        _updateSchwammerlSelectedTrueAll();
                                      }
                                    });
                                    loading = false;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                                ),
                                child: const Text('alle auswählen'),
                              ),
                            ],
                          ),
                        )
                          ],
                    ),
                  ),
                ),
                if (loading == true)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white,),
                    ),
                  ),
                ]
              ),
            ),
          );
        }
    );
  }
}
