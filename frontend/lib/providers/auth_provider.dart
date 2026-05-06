import 'package:flutter/material.dart';
import '../core/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get user => _user;
  String get role => _user?['role'] ?? 'caretaker';
  int? get userId => _user?['id'];

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError('');
    try {
      final response = await ApiService.login(email, password);
      
      if (response.containsKey('error')) {
        _setError(response['error']);
        _setLoading(false);
        return false;
      } else {
        _user = response['user'];
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError('Network error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role, {int? oldAgeHomeId, String? avatarUrl}) async {
    _setLoading(true);
    _setError('');
    try {
      final response = await ApiService.register(name, email, password, role, oldAgeHomeId: oldAgeHomeId, avatarUrl: avatarUrl);
      if (response.containsKey('error')) {
        _setError(response['error']);
        _setLoading(false);
        return false;
      } else {
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError('Network error');
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
