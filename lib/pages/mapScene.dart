// @dart=2.9

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather/weather.dart';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schwammerlapp/auth.dart';
import 'package:schwammerlapp/pages/schwammerlInfo.dart';
import 'package:schwammerlapp/pages/addSchwammerl_add.dart';
import 'package:schwammerlapp/pages/addSchwammerl_home.dart';

class MapScene extends  StatefulWidget {
  @override
  State<MapScene> createState() => _MapSceneState();
}

class _MapSceneState extends State<MapScene> {
  bool servicestatus = false;
  bool haspermission = false;
  LocationPermission permission;
  Position position;
  double long = 0;
  double lat = 0;
  StreamSubscription<Position> positionStream;
  DateTime now = DateTime.now();
  String time;
  String date;
  CameraPosition _initialPosition = CameraPosition(target: LatLng(0, 0), zoom: 16);

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

  Marker origin;
  Marker destination;
  Marker lifeTracking;
  String travelDistance;
  String travelTime;

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    wf = WeatherFactory(weatherAPI, language: Language.GERMAN);
    checkGps();
    markers.clear();
  }

  Widget _title() {
    return const Text('SchwammerlAPP');
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
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

  Widget _showSchwammerlInfoButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShowSchwammerlPage()),
        );
      },
      child: const Text('Schwammerl Info'),
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
          if(markers.isEmpty)
          {
            getGeopoints();
          }
          else
          {
            markers.clear();
            setState(() {

            });
          }
        },
        child: Text(markers.isEmpty ? 'Schwammerlplätze auf Karte anzeigen' : 'Schwammerlplätze auf Karte verdecken'),


      );
  }

  getGeopoints() {
    markers.clear();
    var coordinates = FirebaseFirestore.instance.collection('places');
    coordinates.snapshots().listen((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var geopoint = doc.data()['coords'] as GeoPoint;
        markers.add(Marker(
          markerId: MarkerId(doc.id),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(geopoint.latitude, geopoint.longitude),
        ));
        setState(() {
          //refresh UI
        });
      });
    });
  }

  getAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    //convertToAddress();

    setState(() {
      stAddress = placemarks.first.administrativeArea.toString() + ", " +  placemarks.first.street.toString();
    });
  }

  queryWeather() async {
    Weather weather = await wf.currentWeatherByLocation(lat, long);
    setState(() {
      weatherData = weather.weatherDescription;
    });
  }

  convertToAddress() async {
    Dio dio = Dio();  //initilize dio package
    String apiurl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$googleAPI";

    Response response = await dio.get(apiurl); //send get request to API URL

    if(response.statusCode == 200){ //if connection is successful
      Map data = response.data; //get response data
      if(data["status"] == "OK"){ //if status is "OK" returned from REST API
        if(data["results"].length > 0){ //if there is atleast one address
          Map firstresult = data["results"][0]; //select the first address

          stAddress = firstresult["formatted_address"]; //get the address

          //you can use the JSON data to get address in your own format

          setState(() {
            //refresh UI
          });
        }
      }else{
        print(data["error_message"]);
      }
    }else{
      print("error while fetching geoconding data");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.longitude);
    print(position.latitude);

    long = position.longitude;
    lat = position.latitude;

    routePoints.add(LatLng(lat,long));

    setState(() {
      //refresh UI
    });


    LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      print(position.longitude);
      print(position.latitude);

      long = position.longitude;
      lat = position.latitude;

      routePoints.add(LatLng(lat,long));
      polylineDistance += calculateDistance(routePoints[routePoints.length-2].latitude, routePoints[routePoints.length-2].longitude, routePoints[routePoints.length-1].latitude, routePoints[routePoints.length-1].longitude);

      convertToAddress();

      var newPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15);
      CameraUpdate update =CameraUpdate.newCameraPosition(newPosition);

      mapController.moveCamera(update);


      setState(() {
        //refresh UI on update
      });
    });
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }else if(permission == LocationPermission.deniedForever){
          print("'Location permissions are permanently denied");
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    time = DateFormat('kk:mm').format(now);
    date = DateFormat('dd.MM.yyyy').format(now);
    return Scaffold(
      appBar: AppBar(
          title: _title(),
          backgroundColor: Colors.orange,
      ),
      body: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: true,
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
                _showSchwammerlInfoButton(context),

                _showPlacesOnMapButton(),
                _signOutButton(),
              ],
            ),
          ]
      ),
    );
  }
}


