import 'package:flutter/material.dart';
import '../core/api_service.dart';

class RelativeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  
  Map<String, dynamic>? _resident;
  List<dynamic> _dailyReports = [];
  List<dynamic> _healthReports = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get resident => _resident;
  List<dynamic> get dailyReports => _dailyReports;
  List<dynamic> get healthReports => _healthReports;

  Future<void> fetchReports(int elderlyId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getRelativeReports(elderlyId);
      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        _resident = response['resident'];
        _dailyReports = response['daily_reports'] ?? [];
        _healthReports = response['health_reports'] ?? [];
      }
    } catch (e) {
      _error = 'Failed to load resident reports';
    }

    _isLoading = false;
    notifyListeners();
  }
}
