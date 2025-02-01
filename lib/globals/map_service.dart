import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapService {
  static bool locationDenied = false;

  static bool filtered = false;

  static Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationDenied = true;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        locationDenied = true;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      locationDenied = true;
    }

    if (!locationDenied) {
      Position pos = await Geolocator.getCurrentPosition();
    }
  }
}
