import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAllBusLocations() {
    return _firestore.collection('buses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        if (data.containsKey('position') &&
            data['position'] is GeoPoint &&
            data.containsKey('speed')) {
          GeoPoint geoPoint = data['position'];
          double speed = data['speed'].toDouble();
          return {
            'busId': doc.id,
            'location': LatLng(geoPoint.latitude, geoPoint.longitude),
            'speed': speed
          };
        } else {
          if (kDebugMode) {
            print('Invalid data for doc id: ${doc.id}');
          }
          return {
            'busId': doc.id,
            'location': const LatLng(0, 0),
            'speed': 0.0
          };
        }
      }).toList();
    }).handleError((error) {
      if (kDebugMode) {
        print('Error fetching bus locations: $error');
      }
    });
  }
}
