import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    return http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> post(String endpoint, dynamic data) async {
    return http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> put(String endpoint, dynamic data) async {
    return http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    return http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> login(String email, String password) async {
    return http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register(
    String name,
    String email,
    String password,
    String? phone,
  ) async {
    return http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
  }
}
