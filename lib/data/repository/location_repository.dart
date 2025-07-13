import 'dart:convert';
import 'package:parfumku/data/model/location_model.dart';
import 'package:parfumku/services/http_client_service.dart';

class LocationRepository {
  final HttpClientService _httpClientService = HttpClientService();

  Future<List<LocationModel>> fetchLocations() async {
    try {
      final response = await _httpClientService.get('locations');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          return (jsonResponse['data'] as List)
              .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Failed to load locations: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load locations with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching locations: $e');
      throw Exception('Failed to fetch locations.');
    }
  }

  Future<void> addLocation(LocationModel location) async {
    try {
      final response = await _httpClientService.post(
        'locations',
        location.toJson(), // Kirim body sebagai Map<String, dynamic>
      );

      if (response.statusCode != 201) {
        final jsonResponse = json.decode(response.body);
        throw Exception('Gagal tambah lokasi: ${jsonResponse['message']}');
      }
    } catch (e) {
      print('Error addLocation: $e');
      rethrow;
    }
  }
}
