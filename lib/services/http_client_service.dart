import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parfumku/data/model/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import untuk kDebugMode

class HttpClientService {
  static final HttpClientService _instance = HttpClientService._internal();
  factory HttpClientService() => _instance;
  HttpClientService._internal();

  String? _token;
  Map<String, dynamic>? _user;
  // Sesuaikan IP Anda. Untuk emulator Android, 10.0.2.2 adalah localhost Anda.
  // Untuk perangkat fisik, gunakan IP lokal komputer Anda (misal: 192.168.1.xxx)
  final String baseUrl = 'http://10.0.2.2:3000/api';

  // Getter untuk token (digunakan oleh repository)
  String? get token => _token;

  // Getter untuk user (jika diperlukan)
  Map<String, dynamic>? get user => _user;

  // Simpan token dan user
  Future<void> saveTokenAndUser(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user));
    _token = token;
    _user = user;
    if (kDebugMode) {
      print('Token and user saved: Token=$_token, User=$user');
    }
  }

  // Ambil token dan user dari local storage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding user JSON from SharedPreferences: $e');
        }
        _user = null; // Clear user if decoding fails
      }
    } else {
      _user = null;
    }
    if (kDebugMode) {
      print('Token loaded: $_token');
      print('User loaded: $_user');
    }
  }

  // Hapus token dan user dari local storage (fungsi logout)
  Future<void> clearTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
    _user = null;
    if (kDebugMode) {
      print('Token and user cleared.');
    }
  }

  // Fungsi `logout` yang diminta pengguna
  Future<void> logout() async {
    await clearTokenAndUser(); // Memanggil fungsi clearTokenAndUser yang sudah ada
    if (kDebugMode) {
      print('User logged out successfully.');
    }
  }

  // --- Metode HTTP Generik ---

  // Metode POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
  await loadToken(); // Pastikan token dimuat sebelum setiap request
  final url = Uri.parse('$baseUrl/$endpoint');
  final headers = <String, String>{
    'Content-Type': 'application/json',
  };
  if (_token != null) {
    headers['Authorization'] = 'Bearer $_token';
  }

  if (kDebugMode) {
    print('POST Request to: $url');
    print('Headers: $headers');
    print('Body: ${jsonEncode(body)}');
  }

  return await http.post(
    url,
    headers: headers,
    body: jsonEncode(body), // Convert Map ke JSON
  );
}

  // Metode GET
  Future<http.Response> get(String endpoint) async {
    await loadToken(); // Pastikan token dimuat sebelum setiap request
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json', // GET juga bisa memiliki Content-Type
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (kDebugMode) {
      print('GET Request to: $url');
      print('Headers: $headers');
    }

    return await http.get(url, headers: headers);
  }

  // Metode PUT
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    await loadToken(); // Pastikan token dimuat sebelum setiap request
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (kDebugMode) {
      print('PUT Request to: $url');
      print('Headers: $headers');
      print('Body: ${jsonEncode(body)}');
    }

    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  // Metode DELETE
  Future<http.Response> delete(String endpoint) async {
    await loadToken(); // Pastikan token dimuat sebelum setiap request
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = <String, String>{}; // Umumnya DELETE tidak memerlukan Content-Type
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (kDebugMode) {
      print('DELETE Request to: $url');
      print('Headers: $headers');
    }

    return await http.delete(url, headers: headers);
  }
}