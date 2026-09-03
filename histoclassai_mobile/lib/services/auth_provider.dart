import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userEmail;

  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);
  String? get token => _token;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token != null && !JwtDecoder.isExpired(token)) {
      _token = token;
      _decodeToken();
    } else {
      _token = null;
      await prefs.remove('jwt_token');
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final token = await ApiService.login(email, password);
      if (token != null) {
        _token = token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        _decodeToken();
        notifyListeners();
        return null;
      }
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return "Erreur de connexion";
  }

  void _decodeToken() {
    if (_token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      _userId = decodedToken['sub'];
      _userEmail = decodedToken['email'];
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }
}
