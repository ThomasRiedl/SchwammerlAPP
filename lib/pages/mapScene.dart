// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:weather/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/auth.dart';
import 'package:schwammerlapp/pages/addSchwammerl_add.dart';
import 'package:schwammerlapp/pages/addSchwammerl_home.dart';

class MapScene extends  StatefulWidget {
  @override
  State<MapScene> createState() => _MapSceneState();
}

class _MapSceneState extends State<MapScene> {
  bool servicestatus = false;
  bool haspermission = false;
  Location permission;
  double long = 0;
  double lat = 0;
  DateTime now = DateTime.now();
  String time;
  String date;
  CameraPosition _initialPosition = CameraPosition(target: LatLng(0, 0), zoom: 16);

  double currentLong = 0;
  double currentLat = 0;
  double startlong = 0;
  double startlat = 0;

  final User user = Auth().currentUser;

  Set<Marker> markers = Set();

  List<LatLng> routePoints = [];
  LatLng livePosition;
  double polylineDistance = 0;

  String weatherAPI = "e07b0240f7ecddc73d9bb2191cb76546";
  WeatherFactory wf;
  String weatherData;

  String googleAPI = "AIzaSyCjZ1bWUEJ6k0rNJpimAvhDP1atLcT-mO4";
  String stAddress;
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  bool mapFocused = true;

  GoogleMapController mapController;
  int latlongStartCounter = 1;
  int loadMapCounter = 1;
  int getLoactionOnceCounter = 1;

  double zoomLevel = 15;

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
    wf = WeatherFactory(weatherAPI, language: Language.GERMAN);
    _initialPosition = CameraPosition(target: LatLng(0, 0), zoom: zoomLevel);
    markers.clear();
    getLocation();
  }

  Widget _title() {
    return const Text('SchwammerlAPP');
  }

  Widget _addSchwammerlPlace(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPage()),
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
          MaterialPageRoute(builder: (context) => const AddSchwammerlPage()),
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

  getGeopoints() {
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
        markers.add(Marker(
          markerId: MarkerId(doc.id),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(geopoint.latitude, geopoint.longitude),
        ));
      });
      setState(() {

      });
    });
  }

  getLocationOnce() async{

    LocationData currentLocation;

    currentLong = currentLocation.longitude;
    currentLat = currentLocation.latitude;
    focusCamera(LatLng(currentLat, currentLong));
    setState(() {

    });
  }

  getLocation() async {
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
    return Scaffold(
      appBar: AppBar(
          title: _title(),
          backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
  }
}


