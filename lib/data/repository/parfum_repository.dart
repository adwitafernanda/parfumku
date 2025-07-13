import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Pastikan path ini benar
import '../model/parfum_model.dart';
import '../../services/http_client_service.dart'; // Path disesuaikan jika perlu

class ParfumRepository {
  final HttpClientService _httpClientService = HttpClientService();
  // Asumsi baseUrl di HttpClientService sudah 'http://10.0.2.2:3000/api'
  final String _parfumEndpoint = 'parfum';

  ParfumRepository();

  // --- GET ALL PARFUMS ---
  Future<List<Parfum>> getAllParfums() async {
    http.Response? response;

    try {
      if (kDebugMode) {
        print('Attempting to fetch parfums from: ${_httpClientService.baseUrl}/$_parfumEndpoint');
      }
      response = await _httpClientService.get(_parfumEndpoint);

      if (kDebugMode) {
        print('Response Status Code (getAll): ${response!.statusCode}');
        print('Response Body (getAll): ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> parfumListJson = responseData['data'];
          return parfumListJson.map((json) => Parfum.fromJson(json)).toList();
        } else {
          // Jika respons sukses (statusCode 200) tapi format data tidak valid
          throw Exception('Format respons API tidak valid: ${response.body}');
        }
      } else {
        // Jika statusCode bukan 200
        throw Exception('Failed to load parfums: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      if (kDebugMode) {
        print('Network error: No internet connection or server is unreachable.');
      }
      throw Exception('Tidak ada koneksi internet atau server tidak dapat dijangkau.');
    } on FormatException {
      if (kDebugMode) {
        print('Format error: Invalid JSON response. Body: ${response?.body ?? 'N/A - response was null'}');
      }
      throw Exception('Format respons API tidak valid.');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching parfums: $e');
      }
      throw Exception('Gagal mengambil data parfum: $e');
    }
    // Ini untuk menangani skenario yang sangat tidak mungkin
    // di mana tidak ada return atau throw yang tercapai di atas.
    // Tetap dipertahankan karena ini praktik yang baik.
    throw Exception('Terjadi kesalahan tidak terduga saat mengambil parfum.');
  }

  // --- GET PARFUM BY ID ---
  Future<Parfum> getParfumById(int id) async {
    http.Response? response;
    try {
      response = await _httpClientService.get('$_parfumEndpoint/$id'); // Perbaikan: hapus '/' di awal endpoint

      if (kDebugMode) {
        print('Response Status Code (getById): ${response!.statusCode}');
        print('Response Body (getById): ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return Parfum.fromJson(responseData['data']);
        } else {
          throw Exception('Format respons API (getById) tidak valid: ${response.body}');
        }
      } else {
        throw Exception('Failed to load parfum: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet atau server tidak dapat dijangkau.');
    } on FormatException {
      if (kDebugMode) {
        print('Format error (getById): Invalid JSON response. Body: ${response?.body ?? 'N/A'}');
      }
      throw Exception('Format respons API tidak valid.');
    } catch (e) {
      throw Exception('Gagal mengambil data parfum berdasarkan ID: $e');
    }
  }

  // --- CREATE PARFUM ---
  Future<Parfum> createParfum(Parfum parfum, File? imageFile) async {
    final uri = Uri.parse('${_httpClientService.baseUrl}/$_parfumEndpoint');
    var request = http.MultipartRequest('POST', uri);
    http.StreamedResponse? streamedResponse;
    http.Response? response;

    try {
      await _httpClientService.loadToken(); // Pastikan token dimuat
      if (_httpClientService.token != null) {
        request.headers['Authorization'] = 'Bearer ${_httpClientService.token}';
        if (kDebugMode) {
          print('Authorization Header (Create): Bearer ${_httpClientService.token}');
        }
      } else {
        if (kDebugMode) {
          print('Warning (Create): No token found for authorization.');
        }
      }

      request.fields['name'] = parfum.name;
      request.fields['description'] = parfum.description;
      request.fields['price'] = parfum.price.toString();
      request.fields['stock'] = parfum.stock.toString();
      request.fields['category'] = parfum.category;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Ini HARUS sesuai dengan nama field di backend (multer)
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ));
        if (kDebugMode) {
          print('Adding image file for creation: ${imageFile.path.split('/').last}');
        }
      } else {
        if (kDebugMode) {
          print('No image file provided for creation.');
        }
        // Jika backend membutuhkan image_url meskipun tidak ada file baru,
        // Anda bisa tambahkan request.fields['image_url'] = parfum.imageUrl; di sini.
        // Untuk create, biasanya tidak perlu.
      }

      streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Create Parfum Response Status Code: ${response.statusCode}');
        print('Create Parfum Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return Parfum.fromJson(responseData['data']);
        } else {
          throw Exception('Format respons API (create) tidak valid: ${response.body}');
        }
      } else {
        throw Exception('Failed to create parfum: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet atau server tidak dapat dijangkau.');
    } on FormatException {
      if (kDebugMode) {
        print('Format error (create): Invalid JSON response. Body: ${response?.body ?? 'N/A'}');
      }
      throw Exception('Format respons API tidak valid.');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating parfum: $e');
      }
      throw Exception('Gagal membuat parfum: $e');
    }
  }

  // --- UPDATE PARFUM ---
  Future<Parfum> updateParfum(int id, Parfum parfum, File? imageFile) async {
    final uri = Uri.parse('${_httpClientService.baseUrl}/$_parfumEndpoint/$id');
    var request = http.MultipartRequest('PUT', uri);
    http.StreamedResponse? streamedResponse;
    http.Response? response;

    try {
      await _httpClientService.loadToken(); // Pastikan token dimuat
      if (_httpClientService.token != null) {
        request.headers['Authorization'] = 'Bearer ${_httpClientService.token}';
        if (kDebugMode) {
          print('Authorization Header (Update): Bearer ${_httpClientService.token}');
        }
      } else {
        if (kDebugMode) {
          print('Warning (Update): No token found for authorization.');
        }
      }

      request.fields['name'] = parfum.name;
      request.fields['description'] = parfum.description;
      request.fields['price'] = parfum.price.toString();
      request.fields['stock'] = parfum.stock.toString();
      request.fields['category'] = parfum.category;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Ini HARUS sesuai dengan nama field di backend (multer)
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ));
        if (kDebugMode) {
          print('Adding new image file for update: ${imageFile.path.split('/').last}');
        }
      } else {
        // PERBAIKAN DI SINI: Jika tidak ada file gambar baru,
        // kita tetap kirimkan URL gambar yang sudah ada dari objek parfum.
        // Ini memberi tahu backend untuk mempertahankan gambar yang sudah ada.
        request.fields['image_url'] = parfum.imageUrl; // Menggunakan imageUrl dari objek parfum
        if (kDebugMode) {
          print('No new image file provided, sending existing image_url field: ${parfum.imageUrl}');
        }
      }

      streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Update Parfum Response Status Code: ${response.statusCode}');
        print('Update Parfum Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return Parfum.fromJson(responseData['data']);
        } else {
          throw Exception('Format respons API (update) tidak valid: ${response.body}');
        }
      } else {
        throw Exception('Failed to update parfum: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet atau server tidak dapat dijangkau.');
    } on FormatException {
      if (kDebugMode) {
        print('Format error (update): Invalid JSON response. Body: ${response?.body ?? 'N/A'}');
      }
      throw Exception('Format respons API tidak valid.');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating parfum: $e');
      }
      throw Exception('Gagal memperbarui parfum: $e');
    }
  }

  // --- DELETE PARFUM ---
  Future<void> deleteParfum(int id) async {
    http.Response? response;
    try {
      await _httpClientService.loadToken(); // Pastikan token dimuat
      response = await _httpClientService.delete('$_parfumEndpoint/$id');

      if (kDebugMode) {
        print('Delete Parfum Response Status Code: ${response.statusCode}');
        print('Delete Parfum Response Body: ${response.body}');
      }

      // Kode status 200 OK atau 204 No Content biasanya menandakan sukses untuk DELETE
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete parfum: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet atau server tidak dapat dijangkau.');
    } on FormatException {
      if (kDebugMode) {
        print('Format error (delete): Invalid JSON response. Body: ${response?.body ?? 'N/A'}');
      }
      throw Exception('Format respons API tidak valid.');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting parfum: $e');
      }
      throw Exception('Gagal menghapus parfum: $e');
    }
  }
}