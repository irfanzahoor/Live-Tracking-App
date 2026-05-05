import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_tracking/constants.dart';
import 'package:location/location.dart';

import 'draggable_bottomsheet.dart';

class LiveLocation extends StatefulWidget {
  const LiveLocation({Key? key}) : super(key: key);

  @override
  State<LiveLocation> createState() => LiveLocationPageState();
}

class LiveLocationPageState extends State<LiveLocation> {
  final Completer<GoogleMapController> _googleMapControllerCompleter =
      Completer();
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  bool reachedDestination1 = false;
  bool reachedDestination2 = false;
  bool reachedFinalDestination = false;

  static const LatLng sourceLocation = LatLng(24.9095555, 67.1293434);
  static const LatLng destination1 = LatLng(24.9108635, 67.1274103);
  static const LatLng destination2 = LatLng(24.9108635, 67.1274103);
  static const LatLng destination = LatLng(24.9126923, 67.1256691);

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? currentIcon;

  int activeStep = 0;

  final GlobalKey _sheet = GlobalKey();
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });
    GoogleMapController googleMapController =
        await _googleMapControllerCompleter.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(newLoc.latitude!, newLoc.longitude!), zoom: 16)));

      setState(() {
        updatePolylineColor();
      });
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
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
    currentIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/icons/car.bmp");

    setState(() {});
  }

  void updatePolylineColor() {
    if (!reachedDestination1 &&
        currentLocation != null &&
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ==
            destination1) {
      reachedDestination1 = true;
    }

    if (!reachedDestination2 &&
        currentLocation != null &&
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ==
            destination2) {
      reachedDestination2 = true;
    }

    if (!reachedFinalDestination &&
        currentLocation != null &&
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ==
            destination) {
      reachedFinalDestination = true;
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Rider",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      sourceLocation.latitude,
                      sourceLocation.longitude,
                    ),
                    zoom: 20,
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
                      position: destination2,
                    ),
                    Marker(
                      icon: destinationIcon!,
                      markerId: const MarkerId("destination"),
                      position: destination,
                    ),
                    Marker(
                      icon: currentIcon!,
                      markerId: const MarkerId("currentLocation"),
                      position: currentLocation != null
                          ? LatLng(
                              currentLocation!.latitude!,
                              currentLocation!.longitude!,
                            )
                          : const LatLng(0, 0),
                    ),
                  },
                  polylines: {
                    Polyline(
                      color: reachedFinalDestination
                          ? Colors.blue
                          : (reachedDestination2 ? Colors.blue : Colors.grey),
                      width: 6,
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                    ),
                  },
                  onMapCreated: (mapController) {
                    _googleMapControllerCompleter.complete(mapController);
                  },
                ),
              ),
              const DraggableBottomSheet(),
            ],
          ),
        ],
      ),
    );
  }
}
