import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  final String donationId; // Accept donationId in the constructor
  const Maps({super.key, required this.donationId});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.5004675369126215, 124.84354612960814),
    zoom: 14,
  );

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDropOffLocations();
  }

  Future<void> _fetchDropOffLocations() async {
    try {
      // Access the nested "location" collection within the "donation_drive"
      QuerySnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.donationId)
          .collection('location') // Access the sub-collection
          .get();

      // Add markers for each location document
      setState(() {
        _markers = locationSnapshot.docs.map((doc) {
          GeoPoint geoPoint = doc['location'];
          return Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          );
        }).toSet();
        _isLoading = false;
      });
    } catch (e) {
      // Handle any errors, e.g., no locations found
      setState(() {
        _errorMessage = 'Error fetching locations: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _goToTheTarget() async {
    final GoogleMapController controller = await _controller.future;

    if (_markers.isEmpty) {
      return; // No markers to focus on
    }

    // Calculate the bounds of all markers
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var marker in _markers) {
      final position = marker.position;
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);

    await controller.animateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: _initialPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: _markers,
                      zoomControlsEnabled: true,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer())
                      },
                    ),
          Positioned(
            bottom: 85,
            right: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: _goToTheTarget,
                  backgroundColor: const Color.fromARGB(255, 219, 235, 248),
                  child: const Icon(Icons.pin_drop),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
