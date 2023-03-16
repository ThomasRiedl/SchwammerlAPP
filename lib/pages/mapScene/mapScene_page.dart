// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schwammerlapp/pages/route/route_add.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_add.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_home.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:rxdart/streams.dart';

class MapScenePage extends  StatefulWidget {
  @override
  State<MapScenePage> createState() => _MapScenePageState();
}

class _MapScenePageState extends State<MapScenePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool servicestatus = false;
  bool haspermission = false;
  Location location;
  CameraPosition _initialPosition = CameraPosition(target: LatLng(0, 0), zoom: 16);

  double currentLong = 0;
  double currentLat = 0;

  Set<Marker> markers = Set();

  bool mapFocused = true;
  bool isSelectedSchwammerl = false;

  GoogleMapController mapController;
  int getLoactionOnceCounter = 1;

  String selectedDate = '';

  int checkboxCounter = 0;
  int loadCounter = 1;

  double zoomLevel = 15;

  List<String> autoCompleteDataSchwammerl = [""];
  List<String> autoCompleteDataFilter = [""];
  List<String> selectedSchwammerlName = [];

  TextEditingController searchController;

  final Stream<QuerySnapshot> locationRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('locations').snapshots();
  final Stream<QuerySnapshot> routeRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('routes').snapshots();
  final CollectionReference schwammerlCollection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('locations');

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void focusCamera(LatLng latLng){
    /*mapController.getZoomLevel().then((value) => {
      zoomLevel = value
    });*/
    var newPosition = CameraPosition(
        target: latLng,
        zoom: zoomLevel
    );
    CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);

    mapController.moveCamera(update);
  }

  @override
  void initState() {
    _initialPosition = CameraPosition(target: LatLng(0, 0), zoom: zoomLevel);
    markers.clear();
    getLocation();
  }

  Widget _showPlacesOnMapButton() {
      return ElevatedButton(
        onPressed:(){
          if(markers.length == 1)
          {
            getGeopoints();
          }
          else
          {
            markers.clear();
            markers.add(
                Marker(
                  markerId: MarkerId('lifeTracking'),
                  infoWindow: InfoWindow(title: 'LifeTracking'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  position: LatLng(currentLat, currentLong),
                )
            );
            setState(() {

            });
          }
        },
        child: Text(markers.length == 1 ? 'Schwammerlplätze auf Karte anzeigen' : 'Schwammerlplätze auf Karte verdecken'),
      );
  }

  void getGeopoints() {
    markers.clear();
    markers.add(
        Marker(
          markerId: MarkerId('lifeTracking'),
          infoWindow: InfoWindow(title: 'LifeTracking'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          position: LatLng(currentLat, currentLong),
        )
    );
    var coordinates = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('locations');
    coordinates.snapshots().listen((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var geopoint = doc.data()['coords'] as GeoPoint;
        var name = doc.data()['name'];
        if(searchController.text == "")
        {
          markers.add(Marker(
            markerId: MarkerId(doc.id),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: LatLng(geopoint.latitude, geopoint.longitude),
          ));
        }
        else
        {
          if(name == searchController.text)
          {
            markers.add(Marker(
              markerId: MarkerId(doc.id),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              position: LatLng(geopoint.latitude, geopoint.longitude),
            ));
          }
        }

      });
      setState(() {

      });
    });
  }

  void getLocationOnce() async{

    LocationData currentLocation;

    currentLong = currentLocation.longitude;
    currentLat = currentLocation.latitude;
    focusCamera(LatLng(currentLat, currentLong));
    setState(() {

    });
  }

  void getLocation() async {
    Location location = new Location();
    location.enableBackgroundMode(enable: true);

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    currentLong = _locationData.longitude;
    currentLat = _locationData.latitude;

    location.changeSettings(
      accuracy: LocationAccuracy.navigation,
      distanceFilter: 1,
    );

    setState(() {

    });

    location.onLocationChanged.listen((LocationData currentLocation) {

      currentLong = currentLocation.longitude;
      currentLat = currentLocation.latitude;

      if(mapFocused) {
        focusCamera(LatLng(currentLocation.latitude, currentLocation.longitude));
      }
      setState(() {
        //refresh UI
      });
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs dateRangePickerSelectionChangedArgs)
  {
    if (dateRangePickerSelectionChangedArgs.value.endDate != null) {
      DateTime startDate = dateRangePickerSelectionChangedArgs.value.startDate;
      DateTime endDate = dateRangePickerSelectionChangedArgs.value.endDate;

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

  _clearText() {
    searchController.clear();
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
        padding: EdgeInsets.all(10),
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

  Future<void> _updateSchwammerlSelected(id) {
    isSelectedSchwammerl = false;
    return schwammerlCollection
        .doc(id)
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

  void _showFilter(BuildContext context) {
    final mergedStream = Rx.merge([locationRecords, routeRecords]);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<QuerySnapshot>(
              stream: mergedStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print('Something Wrong in FilterDialog');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final List firebaseDataFilter = [];
                snapshot.data?.docs.map((DocumentSnapshot documentSnapshot) {
                  Map store = documentSnapshot.data() as Map<String, dynamic>;
                  firebaseDataFilter.add(store);
                  store['id'] = documentSnapshot.id;
                }).toList();
                autoCompleteDataFilter.clear();
                for (int i = 0; i < firebaseDataFilter.length; i++) {
                  String name = firebaseDataFilter[i]['name'].toString();
                  autoCompleteDataFilter.add(name);
                }
                if(loadCounter == 1) {
                  for (int i = 0; i < firebaseDataFilter.length; i++) {
                    _updateSchwammerlSelected(firebaseDataFilter[i]['id']);
                  }
                  loadCounter = loadCounter-1;
                }
                return SingleChildScrollView(
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
                                      return List<String>.from(autoCompleteDataFilter);
                                    } else {
                                      return autoCompleteDataFilter.where((word) => word
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
                                          borderSide: BorderSide(color: Colors.grey[300]),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey[300]),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey[300]),
                                        ),
                                        hintText: "Name des Schwammerls",
                                      ),
                                    );
                                  },
                                ),
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
                                    for (var i = 0; i < firebaseDataFilter.length; i++) {
                                      if(searchController.text == firebaseDataFilter[i]['name'])
                                      {
                                        isSelectedSchwammerl = firebaseDataFilter[i]['isSelected'];
                                        isSelectedSchwammerl = !isSelectedSchwammerl;
                                        _updateSchwammerl(firebaseDataFilter[i]['id']);
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
                                      for (var i = 0; i < firebaseDataFilter.length; i++) ...[
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
                                              title: Text(firebaseDataFilter[i]['name']),
                                              subtitle: Text(firebaseDataFilter[i]['info'] == null ? '' : firebaseDataFilter[i]['info']),
                                              secondary: Icon(Icons.travel_explore),
                                              autofocus: false,
                                              checkColor: Colors.white,
                                              selected: firebaseDataFilter[i]['isSelected'],
                                              value: firebaseDataFilter[i]['isSelected'],
                                              onChanged: (newValue) {
                                                setState(() {
                                                  isSelectedSchwammerl = firebaseDataFilter[i]['isSelected'];
                                                  isSelectedSchwammerl = !isSelectedSchwammerl;
                                                  _updateSchwammerl(firebaseDataFilter[i]['id']);
                                                });
                                                selectedSchwammerlName.add(firebaseDataFilter[i]['name']);
                                                if (firebaseDataFilter[i]['isSelected'] == false) {
                                                  print(selectedSchwammerlName);
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
                        ],
                      ),
                    ),
                  );
              }
          ),
        ),
      ),
    ).then((result) {
      setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
      });}
    );
  }

  @override
  Widget build(BuildContext context) {
    if(getLoactionOnceCounter == 1)
    {
      getLocationOnce();
      getLoactionOnceCounter = getLoactionOnceCounter-1;
    }
    markers.removeWhere((marker) => marker.markerId.value == 'lifeTracking');
    markers.add(
        Marker(
          markerId: MarkerId('lifeTracking'),
          infoWindow: InfoWindow(title: 'LifeTracking'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          position: LatLng(currentLat, currentLong),
        )
    );
    return StreamBuilder<QuerySnapshot>(
        stream: locationRecords,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        print('Something Wrong in MapScenePage');
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
     autoCompleteDataSchwammerl.clear();
      for (int i = 0; i < firebaseDataSchwammerl.length; i++) {
        String name = firebaseDataSchwammerl[i]['name'].toString();
        autoCompleteDataSchwammerl.add(name);
      }
      return Scaffold(
          appBar: AppBar(
            title: const Text('SchwammerlAPP'),
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
                        return List<String>.from(autoCompleteDataSchwammerl);
                      } else {
                        return autoCompleteDataSchwammerl.where((word) => word
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
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          hintText: "Schwammerl/Route suchen",
                          prefixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                  ),
                ),
                //IconButton(
                //  icon: Icon(Icons.filter_alt),
                 // onPressed: () {
                 //   _showFilter(context);
                 // },
                //),
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
            AspectRatio(
              aspectRatio: 1,
              child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  onCameraMove:(CameraPosition cameraPosition) {
                    zoomLevel = cameraPosition.zoom;
                  },
                  markers: markers,
                  initialCameraPosition: _initialPosition
              ),
            ),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _showPlacesOnMapButton(),
              ],
            ),
          ]
        ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor:Colors.orange,
          foregroundColor:Colors.white,
          onPressed:()=>{
            setState(() {

            }),
            mapFocused = !mapFocused,
            focusCamera(LatLng(currentLat, currentLong))
          },
          child:const Icon(Icons.navigation),
        ),
      );
    });
  }
}


