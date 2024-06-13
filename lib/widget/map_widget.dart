import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:monitoring/controller/direction_repository.dart';
import 'package:monitoring/firebase/firebase_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen(
      {super.key,
      required void Function(GoogleMapController controller) onMapCreated});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng halteAposition =
      LatLng(-6.972298578308109, 107.63625816087101);
  static const LatLng halteBposition =
      LatLng(-6.937816546171037, 107.62343455506435);

  BitmapDescriptor halteIconA = BitmapDescriptor.defaultMarker;
  BitmapDescriptor halteIconB = BitmapDescriptor.defaultMarker;
  BitmapDescriptor halteIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busIconA = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busIconB = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busIconC = BitmapDescriptor.defaultMarker;

  Map<PolylineId, Polyline> polylines = {};
  late GoogleMapController mapController;
  String? mapStyle;

  Set<Marker> markers = {};

  FirebaseService firebaseService = FirebaseService();
  DirectionsRepository directionsRepository = DirectionsRepository(dio: Dio());

  @override
  void initState() {
    super.initState();
    loadMapStyle();
    getPolyPoints();
    setCustomMarkerIcon();
    addStaticMarkers();
  }

  Future<void> loadMapStyle() async {
    final String style =
        await rootBundle.loadString('assets/maps_style_drs.json');
    if (mounted) {
      setState(() {
        mapStyle = style;
      });
    }
  }

  Future<void> getPolyPoints() async {
    try {
      final directions = await directionsRepository.getDirections(
        origin: halteAposition,
        destination: halteBposition,
      );

      if (mounted &&
          directions != null &&
          directions.polylinePoints.isNotEmpty) {
        setState(() {
          polylines[const PolylineId("route")] = Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blueAccent,
            points: directions.polylinePoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(),
          );
        });
      } else {
        if (kDebugMode) {
          print("Failed to get route points");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching directions: $e");
      }
    }
  }

  Future<void> setCustomMarkerIcon() async {
    const ImageConfiguration config =
        ImageConfiguration(size: Size(50.0, 50.0));
    halteIconA = await BitmapDescriptor.fromAssetImage(
        config, "images/icon_halte_A.png");
    halteIconB = await BitmapDescriptor.fromAssetImage(
        config, "images/icon_halte_B.png");
    halteIcon =
        await BitmapDescriptor.fromAssetImage(config, "images/halte_icon.png");
    busIconA = await BitmapDescriptor.fromAssetImage(
        config, "images/icon_bus_red.png");
    busIconB = await BitmapDescriptor.fromAssetImage(
        config, "images/icon_bus_yellow.png");
    busIconC = await BitmapDescriptor.fromAssetImage(
        config, "images/icon_bus_blue.png");

    addStaticMarkers();
  }

  void updateBusMarkers(List<Map<String, dynamic>> busLocations) {
    Set<Marker> newMarkers = {};

    newMarkers.addAll(markers);

    for (var bus in busLocations) {
      LatLng position = bus['location'];
      if (position.latitude != 0 && position.longitude != 0) {
        BitmapDescriptor icon;
        switch (bus['busId']) {
          case 'bus1':
            icon = busIconA;
            break;
          case 'bus2':
            icon = busIconB;
            break;
          case 'bus3':
            icon = busIconC;
            break;
          default:
            icon = halteIcon;
        }
        newMarkers.add(
          Marker(
            markerId: MarkerId(bus['busId']),
            icon: icon,
            position: position,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        markers = newMarkers;
      });
    }
  }

  void addStaticMarkers() {
    markers.add(
      Marker(
        markerId: const MarkerId("halte_A"),
        icon: halteIconA,
        position: halteAposition,
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId("halte_B"),
        icon: halteIconB,
        position: halteBposition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.9589278, 107.6366338),
                zoom: 14,
              ),
              mapType: MapType.normal,
              trafficEnabled: true,
              polylines: Set<Polyline>.of(polylines.values),
              markers: markers,
              style: mapStyle,
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getAllBusLocations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                if (kDebugMode) {
                  print("Error: ${snapshot.error}");
                }
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  updateBusMarkers(snapshot.data!);
                });

                return Container();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
