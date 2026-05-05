import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_tracking/constants.dart';

class MarkersCheck extends StatefulWidget {
  const MarkersCheck({Key? key}) : super(key: key);

  @override
  State<MarkersCheck> createState() => MarkersCheckPageState();
}

class MarkersCheckPageState extends State<MarkersCheck> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  static const LatLng sourceLocation = LatLng(25.267311, 55.3549666);
  static const LatLng destination1 = LatLng(25.1972295, 55.279747);
  static const LatLng destination = LatLng(25.0976119, 55.163109);

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result1 = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination1.latitude, destination1.longitude),
    );

    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(destination1.latitude, destination1.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result1.points.isNotEmpty && result2.points.isNotEmpty) {
      for (var point in result1.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      for (var point in result2.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  void setCustomMarkerIcon() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/icons/Pin_source.bmp");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/icons/Pin_destination.bmp");

    setState(() {});
  }

  @override
  void initState() {
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: sourceLocation,
          zoom: 10,
        ),
        markers: {
          Marker(
            icon: sourceIcon!,
            markerId: const MarkerId("source"),
            position: sourceLocation,
          ),
          Marker(
            icon: destinationIcon!,
            markerId: const MarkerId("destination1"),
            position: destination1,
          ),
          Marker(
            icon: destinationIcon!,
            markerId: const MarkerId("destination2"),
            position: destination,
          ),
        },
        polylines: {
          Polyline(
            color: Colors.blue,
            width: 6,
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
          ),
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        },
      ),
    );
  }
}
