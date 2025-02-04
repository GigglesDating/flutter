import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../utilitis/appColors.dart';

class SosMapPage extends StatefulWidget {
  @override
  _SosMapPage createState() => _SosMapPage();
}

class _SosMapPage extends State<SosMapPage> {
  GoogleMapController? mapController;

  // BitmapDescriptor? customIcon;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // final LatLng _center = LatLng(12.934056, 77.610116); // Replace with your location
  LatLng? _currentLocation; // Default location (e.g., San Francisco)
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addMarkerWithRadialEffect(_currentLocation!);
    });
  }

  // Future<void> _loadCustomMarkerIcon() async {
  //   customIcon = await BitmapDescriptor.asset(
  //     ImageConfiguration(size: Size(36, 36)), // Adjust size as needed
  //     'assets/images/pin_icon.png',
  //   );
  //   setState(() {}); // Refresh to show custom marker
  // }

  void _addMarkerWithRadialEffect(LatLng position) {
    setState(() {
      // Add the main marker
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: position,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );

      // Add circles for the radial effect
      _circles = {
        Circle(
          circleId: CircleId("circle1"),
          center: position,
          radius: 100,
          // radius in meters
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue.withOpacity(0.3),
          strokeWidth: 1,
        ),
        Circle(
          circleId: CircleId("circle2"),
          center: position,
          radius: 200,
          // larger radius for outer effect
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue.withOpacity(0.1),
          strokeWidth: 1,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentLocation == null
              ? Center(
                  child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.tertiary,
                )) // Loading indicator
              : GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                      if (_locationFetched) {
                        mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: _currentLocation!, zoom: 15.0),
                          ),
                        );
                      }
                    });
                  },
                  initialCameraPosition:
                      CameraPosition(target: _currentLocation!, zoom: 15),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  circles: _circles,
                  markers:
                      // customIcon == null
                      //     ? {}
                      //     :
                      _markers,
                ),
          Positioned(
              top: kToolbarHeight,
              left: 16,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24))),
                      backgroundColor: WidgetStatePropertyAll(AppColors.black),
                      padding: WidgetStatePropertyAll(EdgeInsets.only(
                        left: Platform.isIOS ? 8 : 0,
                      ))),
                  icon: Icon(
                    Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                    color: AppColors.white,
                  )))
          // Overlay the concentric circles
          // Positioned(
          //   left: MediaQuery.of(context).size.width / 2 - 64,
          //   top: MediaQuery.of(context).size.height / 2 - 91, // Adjust for alignment
          //   child:
          //   CustomPaint(
          //     size: Size(140, 140), // Set size for the concentric circles
          //     painter: ConcentricCirclesPainter(),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double radiusIncrement = size.width / 10;
    for (double i = radiusIncrement; i < size.width / 2; i += radiusIncrement) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), i, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}