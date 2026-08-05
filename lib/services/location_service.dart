import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class LocationService {
  static bool _tracking = false;
  static StreamSubscription<Position>? _positionSubscription;

  static Future<bool> requestPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return false;
    return true;
  }

  static void startTracking(String driverId) {
    _tracking = true;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!_tracking) return;
      FirestoreService.updateDriverLocation(driverId, position.latitude, position.longitude);
    });
  }

  static Future<void> stopTracking(String driverId) async {
    _tracking = false;
    await _positionSubscription?.cancel();
    await FirestoreService.updateDriverLocation(driverId, 0, 0);
  }

  static double calculateDistance(
    double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
