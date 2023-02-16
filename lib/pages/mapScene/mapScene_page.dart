// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/pages/route/route_add.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_add.dart';
import 'package:schwammerlapp/pages/schwammerl/schwammerl_home.dart';
import 'package:substring_highlight/substring_highlight.dart';

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

  GoogleMapController mapController;
  int getLoactionOnceCounter = 1;

  double zoomLevel = 15;

  List<String> autoCompleteDataSchwammerl = [""];

  TextEditingController searchController;

  final Stream<QuerySnapshot> locationRecords = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid.toString()).collection('locations').snapshots();

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

  Widget _addSchwammerlPlace(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SchwammerlAddPage()),
        );
      },
      child: const Text('Schwammerlplatz hinzufügen'),
    );
  }

  Widget _AddRouteButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RouteAddPage()),
        );
      },
      child: const Text('Schwammerlplatz hinzufügen'),
    );
  }

  Widget _showSchwammerlPlaces(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SchwammerlHomePage()),
        );
      },
      child: const Text('Schwammerlplätze ansehen'),
    );
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
      autoCompleteDataSchwammerl.add("");
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
            Autocomplete(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return autoCompleteDataSchwammerl;
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
                _addSchwammerlPlace(context),
                _showSchwammerlPlaces(context),
                _showPlacesOnMapButton(),
                _AddRouteButton(context),
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


