import 'dart:async';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'constants.dart';

class DraggableBottomSheet extends StatefulWidget {
  const DraggableBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  bool reachedDestination1 = false;
  bool reachedDestination2 = false;
  bool reachedFinalDestination = false;
  bool bottomSheetOpen = false;

  static const LatLng sourceLocation = LatLng(24.9095555, 67.1293434);
  static const LatLng destination1 = LatLng(24.9108635, 67.1274103);
  static const LatLng destination2 = LatLng(24.9108635, 67.1274103);
  static const LatLng destination = LatLng(24.9126923, 67.1256691);

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? currentIcon;

  int activeStep = 0;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });
    GoogleMapController googleMapController = await _controller.future;
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

  void updatePolylineColor() {
    if (!reachedDestination1 &&
        currentLocation != null &&
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ==
            destination1) {
      reachedDestination1 = true;
      activeStep = 1;
    }

    if (!reachedDestination2 &&
        currentLocation != null &&
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ==
            destination2) {
      reachedDestination2 = true;
      activeStep = 2;
    }

    if (!reachedFinalDestination &&
        currentLocation != null &&
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ==
            destination) {
      reachedFinalDestination = true;
      activeStep = 3;
    }
    setState(() {});
  }

  @override
  void initState() {
    getCurrentLocation();

    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          bottomSheetOpen = details.primaryDelta! < 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: bottomSheetOpen
            ? MediaQuery.of(context).size.height * 0.90
            : MediaQuery.of(context).size.height * 0.40,
        curve: Curves.bounceIn,
        child: SingleChildScrollView(
          child: Transform.translate(
            offset: bottomSheetOpen
                ? Offset(0.0, MediaQuery.of(context).size.height * 0.50)
                : Offset.zero,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: EasyStepper(
                activeStep: activeStep,
                textDirection: TextDirection.ltr,
                stepShape: StepShape.rRectangle,
                stepBorderRadius: 15,
                borderThickness: 2,
                internalPadding: 10,
                direction: Axis.vertical,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                stepRadius: 28,
                finishedStepBorderColor: Colors.greenAccent,
                finishedStepTextColor: Colors.greenAccent,
                finishedStepBackgroundColor: Colors.deepOrange,
                activeStepIconColor: Colors.deepOrange,
                showLoadingAnimation: false,
                steps: const [
                  EasyStep(
                    title: 'source location',
                    icon: Icon(Icons.location_on),
                  ),
                  EasyStep(
                    title: 'point 1',
                    icon: Icon(Icons.location_on),
                  ),
                  EasyStep(
                    title: 'point 2',
                    icon: Icon(Icons.location_on),
                  ),
                  EasyStep(
                    title: 'destination',
                    icon: Icon(Icons.location_on),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
