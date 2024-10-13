import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Navigate extends StatefulWidget {
  final String locationId;
  final String donationDriveId;

  const Navigate({
    super.key,
    required this.locationId,
    required this.donationDriveId,
  });

  @override
  State<Navigate> createState() => MapSampleState();
}

class MapSampleState extends State<Navigate> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? _markerPosition;
  Marker? _marker;
  bool _isLoading = true;
  final Set<Polyline> _polyline = {};
  LatLng? currentLocation;
  LatLng midpoint = LatLng(6.5004675369126215, 124.84354612960814);
  String googleApiKey = 'AIzaSyBGk1tV54PEFJccawpftei5hZ_8zr404c0';

  @override
  void initState() {
    super.initState();
    _fetchMarker();
  }

  Future<void> _fetchMarker() async {
    try {
      // Fetch current location
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLocation =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      // Fetch marker position from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("donation_drive")
          .doc(widget.donationDriveId)
          .collection("location")
          .doc(widget.locationId)
          .get();

      GeoPoint geoPoint = doc['location'];
      _markerPosition = LatLng(geoPoint.latitude, geoPoint.longitude);
      _marker = Marker(
        markerId: const MarkerId('marker_id'),
        position: _markerPosition!,
        infoWindow: InfoWindow(title: doc['exactAdress']),
      );

      setState(() {
        // Calculate midpoint
        midpoint = calculateMidpoint(_markerPosition, currentLocation);
      });

      // Fetch route and update polyline
      await _fetchRoute();

      // Move the camera to the new midpoint
      await _moveCameraToMidpoint();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  LatLng calculateMidpoint(LatLng? pointA, LatLng? pointB) {
    if (pointA == null || pointB == null) return midpoint;

    double midLatitude = (pointA.latitude + pointB.latitude) / 2;
    double midLongitude = (pointA.longitude + pointB.longitude) / 2;

    return LatLng(midLatitude, midLongitude);
  }

  Future<void> _moveCameraToMidpoint() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: midpoint,
          zoom: 10.3746,
        ),
      ),
    );
  }

  CameraPosition _getInitialCameraPosition() {
    return CameraPosition(
      target: midpoint,
      zoom: 10.3746,
    );
  }

  Future<void> _fetchRoute() async {
    try {
      List<LatLng> routePoints =
          await _getRouteCoordinates(currentLocation!, _markerPosition!);
      setState(() {
        _polyline.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<List<LatLng>> _getRouteCoordinates(
      LatLng origin, LatLng destination) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey';

    http.Response response = await http.get(Uri.parse(url));
    Map data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      List steps = data['routes'][0]['legs'][0]['steps'];
      List<LatLng> routePoints = [];

      for (var step in steps) {
        String polyline = step['polyline']['points'];
        routePoints.addAll(_decodePolyline(polyline));
      }
      return routePoints;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> decodedPoints = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      decodedPoints.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return decodedPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _getInitialCameraPosition(),
            myLocationEnabled: true,
            markers: _marker != null ? {_marker!} : {},
            polylines: _polyline,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 60,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: const Text(
                    'Navigate',
                    style: TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
