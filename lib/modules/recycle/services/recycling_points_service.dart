import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:flutter_app_base/data/models/recycling_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class RecyclingPointsService {
  static List<RecyclingPointModel>? _cachedPoints;

  static Future<List<RecyclingPointModel>> _getAllRecyclingPoints() async {
    if (_cachedPoints != null) {
      return _cachedPoints!;
    }

    _cachedPoints = await _loadFromJson();
    return _cachedPoints!;
  }

  // Load from JSON asset
  static Future<List<RecyclingPointModel>> _loadFromJson() async {
    // debug print
    print('Loading recycling points from JSON...');

    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString('assets/recycling_points.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Convert to models and cache in memory
      final allPoints = jsonList.map((json) => RecyclingPointModel.fromJson(json)).toList();

      return allPoints;
    } catch (e) {
      throw Exception('Failed to load recycling points: $e');
    }
  }

  // Get nearby points within radius
  static Future<List<RecyclingPointModel>> getNearbyPoints({
    required double userLat,
    required double userLng,
  }) async {

    final allPoints = await _getAllRecyclingPoints(); // Get all cached points
    final nearbyPoints = <RecyclingPointModel>[];

    for (final point in allPoints) {
      final distance = _calculateDistance(userLat, userLng, point.latitude, point.longitude);
      
      if (distance <= AppConfig.recyclingPointsRadiusKm) {
        nearbyPoints.add(point.copyWithDistance(distance));
      }
    }

    // Sort by distance (closest first)
    nearbyPoints.sort((a, b) => a.distance.compareTo(b.distance));
    
    return nearbyPoints;
  }

  // Check location permission and get current location
  static Future<Position?> getCurrentLocation({required bool requestPermission}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (requestPermission) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate straight-line distance between two coordinates
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Clear memory cache (useful for debugging)
  static void clearCache() {
    _cachedPoints = null;
  }

  static void openInMaps(BuildContext context, RecyclingPointModel point) async {
    // Try geo URI first (opens native maps app)
    final geoUri = Uri.parse('geo:${point.latitude},${point.longitude}?q=${point.latitude},${point.longitude}(${Uri.encodeComponent(point.name)})');
    
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to web Google Maps
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}');
    
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Show error if nothing works
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
