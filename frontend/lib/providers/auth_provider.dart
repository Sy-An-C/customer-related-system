import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://your-api-base-url.com';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      await autoLogin();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _user = User.fromJson(data['user']);

        await _storage.write(key: 'token', value: _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error =
            data['message'] ?? 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> autoLogin() async {
    try {
      final response = await _apiService.get('user');
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
        notifyListeners();
      } else {
        _token = null;
        await _storage.delete(key: 'token');
      }
    } catch (e) {
      _token = null;
      await _storage.delete(key: 'token');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('logout', {});
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    await _storage.delete(key: 'token');
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('user', {
        'name': name,
        'email': email,
        'phone': phone,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password, phone);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        _user = User.fromJson(data['user']);

        await _storage.write(key: 'token', value: _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
