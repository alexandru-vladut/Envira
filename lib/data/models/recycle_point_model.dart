import 'package:cloud_firestore/cloud_firestore.dart';

class RecyclePointModel {
  final String? docId; // Firestore document ID (null when creating instance)
  final int id; // The API ID from hartareciclarii.ro
  final String name;
  final GeoPoint coordinates; // Using Firestore's GeoPoint for latlng compatibility
  final String subheading;
  final String address;
  final bool offersMoney;
  final double distance; // Distance from current location in kilometers

  RecyclePointModel({
    this.docId,
    required this.id,
    required this.name,
    required this.coordinates,
    required this.subheading,
    required this.address,
    required this.offersMoney,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coordinates': coordinates,
      'subheading': subheading,
      'address': address,
      'offersMoney': offersMoney,
      'distance': distance,
    };
  }

  factory RecyclePointModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception(
        'doc.data() is null for docId ${doc.id}, cannot convert to RecyclePointModel.',
      );
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return RecyclePointModel(
        docId: doc.id,
        id: data['id'],
        name: data['name'],
        coordinates: data['coordinates'] as GeoPoint,
        subheading: data['subheading'],
        address: data['address'],
        offersMoney: data['offersMoney'],
        distance: data['distance'].toDouble(),
      );
    } catch (e) {
      throw Exception(
        'Error converting document snapshot fields to RecyclePointModel fields: $e',
      );
    }
  }

  // Helper factory to create from hartareciclarii.ro API response
  factory RecyclePointModel.fromApiResponse({
    required int id,
    required String name,
    required List<double> latlng, // [lat, lng] from API
    required String subheading,
    required String address,
    required bool offersMoney,
    required double distance, // Distance in kilometers
  }) {
    return RecyclePointModel(
      id: id,
      name: name,
      coordinates: GeoPoint(latlng[0], latlng[1]), // Convert to GeoPoint
      subheading: subheading,
      address: address,
      offersMoney: offersMoney,
      distance: distance,
    );
  }

  // Helper getters for easy access to lat/lng
  double get latitude => coordinates.latitude;
  double get longitude => coordinates.longitude;
  
  // Helper method to get coordinates as List<double> for API calls
  List<double> get latlngList => [coordinates.latitude, coordinates.longitude];

  // Helper method to get formatted distance string
  String get formattedDistance {
    if (distance < 1.0) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}
