// @dart=2.9

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
  MapType _currentMapType = MapType.normal;

  String startDateString = '';
  String endDateString = '';
  DateTime startDate;
  DateTime endDate;
  DateTime dateTime;

  int selectCounter = 0;
  int resetDate = 0;

  List<String> autoCompleteDataSchwammerl = [""];
  List<String> autoCompleteDataFilter = [""];
  List<String> selectedSchwammerlName = [];

  TextEditingController searchController;

  final Stream<QuerySnapshot> locationRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('locations').snapshots();
  final Stream<QuerySnapshot> routeRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('routes').snapshots();
  final Stream<QuerySnapshot> allRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('all').snapshots();

  final CollectionReference schwammerlCollection = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('locations');

  final mainColor = const Color(0xFFf8cdd1);
  final secondaryColor = const Color(0xFF2D2E37);

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

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final byteData = await rootBundle.load(path);
    final codec = await instantiateImageCodec(byteData.buffer.asUint8List(), targetWidth: width);
    final frameInfo = await codec.getNextFrame();
    final bytes = (await frameInfo.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
    setState(() {
      // update state here
    });
    return bytes;
  }

  void getGeopoints() {
    markers.clear();
    markers.add(
        Marker(
          markerId: MarkerId('lifeTracking'),
          infoWindow: InfoWindow(title: 'LifeTracking'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(currentLat, currentLong),
        )
    );
    var coordinates = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('all');
    coordinates.snapshots().listen((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        var name = doc.data()['name'];
        if(searchController.text == "")
        {
          if (doc.data()['schwammerlCoords'] != null) {
            List<dynamic> coordsList = doc.data()['schwammerlCoords'];
            coordsList.asMap().forEach((index, coords) async {
              var geopoint = doc.data()['schwammerlCoords'][index] as GeoPoint;
              markers.add(Marker(
                markerId: MarkerId(index.toString()),
                icon: BitmapDescriptor.fromBytes(
                    await _getBytesFromAsset('assets/images/mushroom_map.png', 100),
               ),
                position: LatLng(geopoint.latitude, geopoint.longitude),
              ));
            });
            setState(() {

            });
          }
          if (doc.data()['coords'] != null) {
            var geopoint = doc.data()['coords'] as GeoPoint;
            markers.add(Marker(
              markerId: MarkerId(doc.id),
              icon: BitmapDescriptor.fromBytes(
                  await _getBytesFromAsset('assets/images/mushroom_map.png', 100),
            ),
              position: LatLng(geopoint.latitude, geopoint.longitude),
            ));
          }
        }
        else
        {
          if(name == searchController.text)
          {
            if (doc.data()['schwammerlCoords'] != null) {
              List<dynamic> coordsList = doc.data()['schwammerlCoords'];
              coordsList.asMap().forEach((index, coords) async {
                var geopoint = doc.data()['schwammerlCoords'][index] as GeoPoint;
                markers.add(Marker(
                  markerId: MarkerId(index.toString()),
                  icon: BitmapDescriptor.fromBytes(
                      await _getBytesFromAsset('assets/images/mushroom.png', 100),
                ),
                  position: LatLng(geopoint.latitude, geopoint.longitude),
                ));
              });
            }
            if (doc.data()['coords'] != null) {
              var geopoint = doc.data()['coords'] as GeoPoint;
              markers.add(Marker(
                markerId: MarkerId(doc.id),
                icon: BitmapDescriptor.fromBytes(
                  await _getBytesFromAsset('assets/images/mushroom_map.png', 100),
                ),
                position: LatLng(geopoint.latitude, geopoint.longitude),
              ));
            }
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
      startDate = dateRangePickerSelectionChangedArgs.value.startDate;
      endDate = dateRangePickerSelectionChangedArgs.value.endDate;
      selectCounter = 1;
      startDateString = '${startDate.day}.${_twoDigitString(startDate.month)}.${_twoDigitString(startDate.year)}';
      endDateString = '${endDate.day}.${_twoDigitString(endDate.month)}.${_twoDigitString(endDate.year)}';

      setState(() {
        selectedDate = '$startDateString - $endDateString';
      });
      var snackBarDate = SnackBar(
        content: Text('Zeitraum $selectedDate ausgewählt'),
      );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBarDate);
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
                rangeSelectionColor: mainColor,
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
          searchController.clear();
          List firebaseDataSchwammerlDate = [];
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser.uid.toString())
              .collection('locations')
              .snapshots()
              .listen((QuerySnapshot snapshot) async {
            snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
              Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
              data['id'] = documentSnapshot.id;
              firebaseDataSchwammerlDate.add(data);
            });
            for (int i = 0; i < firebaseDataSchwammerlDate.length; i++) {
              String pickedDate = firebaseDataSchwammerlDate[i]['date'].toString();
              String id = firebaseDataSchwammerlDate[i]['id'].toString();
              dateTime = DateTime.parse(pickedDate);
              if (dateTime.isAfter(startDate) && dateTime.isBefore(endDate)) {
                var geopoint = firebaseDataSchwammerlDate[i]['coords'] as GeoPoint;
                markers.add(Marker(
                  markerId: MarkerId(id),
                  icon: BitmapDescriptor.fromBytes(
                      await _getBytesFromAsset('assets/images/mushroom_map.png', 100),
                ),
                  position: LatLng(geopoint.latitude, geopoint.longitude),
                ));
              }
            }
            resetDate = 1;
          });
          FocusManager.instance.primaryFocus?.unfocus();
        });
      }}
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(currentLat, currentLong),
        )
    );
    return StreamBuilder<QuerySnapshot>(
        stream: allRecords,
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
          child: SingleChildScrollView(
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
                            color: Color.fromRGBO(231, 195, 198, 1.0),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height-151,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GoogleMap(
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: _onMapCreated,
                        myLocationButtonEnabled: true,
                        zoomGesturesEnabled: true,
                        tiltGesturesEnabled: false,
                        onCameraMove:(CameraPosition cameraPosition) {
                          zoomLevel = cameraPosition.zoom;
                        },
                        markers: markers,
                        mapType: _currentMapType,
                        initialCameraPosition: _initialPosition
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 30,
              child: FloatingActionButton(
                backgroundColor: secondaryColor,
                foregroundColor: mainColor,
                onPressed: () {
                  _currentMapType = (_currentMapType == MapType.normal) ? MapType.hybrid : MapType.normal;
                  setState(() {
                  });
                },
                child: const Icon(Icons.map),
              ),
            ),
            Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width/2-12.5,
              child: FloatingActionButton(
                backgroundColor: secondaryColor,
                foregroundColor: mainColor,
                onPressed:() async {
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
                          icon: BitmapDescriptor.fromBytes(
                              await _getBytesFromAsset('assets/images/mushroom_map.png', 100),
                        ),
                          position: LatLng(currentLat, currentLong),
                        )
                    );
                    setState(() {

                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Image.asset('assets/images/mushroom_pink.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                backgroundColor: secondaryColor,
                foregroundColor: mainColor,
                onPressed: () {
                  setState(() {
                  });
                  mapFocused = !mapFocused;
                  focusCamera(LatLng(currentLat, currentLong));
                },
                child: const Icon(Icons.navigation),
              ),
            ),
          ],
        ),
      );
    });
  }
}