import 'package:flutter/material.dart';
import '../core/api_service.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  List<dynamic> _users = [];
  List<dynamic> _residents = [];
  int _caretakerCount = 0;

  List<dynamic> _reports = [];
  List<dynamic> _systemAlerts = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  List<dynamic> get users => _users;
  List<dynamic> get residents => _residents;
  List<dynamic> get reports => _reports;
  List<dynamic> get systemAlerts => _systemAlerts;
  int get caretakerCount => _caretakerCount;

  Future<void> fetchSystemOverview() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getAllData();
      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        _users = response['users'] ?? [];
        _caretakerCount = _users.where((u) => u['role'] == 'caretaker').length;
        _reports = response['daily_reports'] ?? [];
        _systemAlerts = _reports.where((r) => r['issues'] != null && r['issues'].toString().trim().isNotEmpty).toList();
      }
    } catch (e) {
      _error = 'Failed to load system overview';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchResidents(int homeId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getResidentsByHome(homeId);
      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        _residents = response['residents'] ?? [];
      }
    } catch (e) {
      _error = 'Failed to fetch residents';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> addResident(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.addResident(data);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return {'success': false};
      } else {
        // Refresh list
        if (data.containsKey('old_age_home_id')) {
          await fetchResidents(data['old_age_home_id']);
        }
        return {
          'success': true,
          'relative_email': response['relative_email'],
          'relative_password': response['relative_password'],
        };
      }
    } catch (e) {
      _error = 'Failed to add resident';
      _isLoading = false;
      notifyListeners();
      return {'success': false};
    }
  }

  Future<bool> updateFacilityImage(int homeId, String imageUrl) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.updateHomeImage(homeId, imageUrl);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update facility image';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
