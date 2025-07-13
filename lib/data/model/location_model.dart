import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final DateTime createdAt;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.createdAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      // 'created_at': createdAt.toIso8601String(), // jika backend butuh
    };
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, description, createdAt];
}
