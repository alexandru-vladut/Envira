class RecyclingPointModel {
  final int id;
  final String name;
  final List<double> latlng; // [lat, lng]
  final String subheading;
  final String address;
  final List<String> materials;
  final bool offersMoney;
  final double distance; // Will be calculated when filtering

  RecyclingPointModel({
    required this.id,
    required this.name,
    required this.latlng,
    required this.subheading,
    required this.address,
    required this.materials,
    required this.offersMoney,
    this.distance = 0.0,
  });

  // Factory to create from JSON
  factory RecyclingPointModel.fromJson(Map<String, dynamic> json) {
    return RecyclingPointModel(
      id: json['id'],
      name: json['name'] ?? '',
      latlng: List<double>.from(json['latlng']),
      subheading: json['subheading'] ?? '',
      address: json['address'] ?? '',
      materials: List<String>.from(json['materials'] ?? []),
      offersMoney: json['info']['offers_money'] ?? false,
    );
  }

  // Helper getters
  double get latitude => latlng[0];
  double get longitude => latlng[1];

  // Create a copy with updated distance
  RecyclingPointModel copyWithDistance(double newDistance) {
    return RecyclingPointModel(
      id: id,
      name: name,
      latlng: latlng,
      subheading: subheading,
      address: address,
      materials: materials,
      offersMoney: offersMoney,
      distance: newDistance,
    );
  }

  // Helper method to get formatted distance string
  String get formattedDistance {
    if (distance < 1.0) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}
