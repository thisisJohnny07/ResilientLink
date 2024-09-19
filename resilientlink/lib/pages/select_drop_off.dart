import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resilientlink/pages/aid_donation_Confirmation.dart';

class SelectDropOff extends StatefulWidget {
  final List<Map<String, String>> items;
  final String donationId;

  const SelectDropOff(
      {super.key, required this.items, required this.donationId});

  @override
  State<SelectDropOff> createState() => _MapsState();
}

class _MapsState extends State<SelectDropOff> {
  Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  String? _selectedMarkerId; // Variable to keep track of the selected marker ID

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
      QuerySnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.donationId)
          .collection('location')
          .get();

      setState(() {
        _markers = locationSnapshot.docs.map((doc) {
          GeoPoint geoPoint = doc['location'];
          return Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            onTap: () {
              // Update the selected marker ID when a marker is tapped
              setState(() {
                _selectedMarkerId = doc.id;
              });
            },
          );
        }).toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching locations: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _goToTheTarget() async {
    final GoogleMapController controller = await _controller.future;

    if (_markers.isEmpty) {
      return;
    }

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

  void _onSelectButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AidDonationConfirmation(
          items: widget.items,
          donationDriveId: widget.donationId,
          locationId: _selectedMarkerId.toString(),
        ),
      ),
    );
    if (_selectedMarkerId != null) {
      // Print the ID of the selected marker
      print('Selected marker ID: $_selectedMarkerId');
    } else {
      print('No marker selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              "Step 2:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Select drop-off point",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        toolbarHeight: 60,
      ),
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
      bottomNavigationBar: BottomAppBar(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _selectedMarkerId == null ? null : _onSelectButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF015490),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Select",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
