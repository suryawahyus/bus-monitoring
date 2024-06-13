import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:monitoring/controller/api_key.dart';
import 'package:monitoring/controller/direction_model.dart';

class DirectionsRepository {
  final Dio dio;

  DirectionsRepository({required this.dio});

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/directions/json';
    final response = await dio.get(baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': googleMapApi,
      'mode': 'driving'
    });

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  Future<Map<String, dynamic>?> getEta({
    required LatLng origin,
    required LatLng destination,
  }) async {
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/distancematrix/json';
    final response = await dio.get(baseUrl, queryParameters: {
      'origins': '${origin.latitude},${origin.longitude}',
      'destinations': '${destination.latitude},${destination.longitude}',
      'key': googleMapApi,
      'traffic_model': 'best_guess',
      'departure_time': 'now',
      'mode': 'driving'
    });

    if (response.statusCode == 200 &&
        response.data['rows'][0]['elements'][0]['status'] == 'OK') {
      var element = response.data['rows'][0]['elements'][0];
      var durationInTraffic = element['duration_in_traffic'];
      var distance = element['distance'];
      return {
        'duration': durationInTraffic['text'],
        'duration_value': durationInTraffic['value'],
        'distance_value': distance['value']
      };
    } else {
      throw Exception('Failed to fetch ETA');
    }
  }
}
