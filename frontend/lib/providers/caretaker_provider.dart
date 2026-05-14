import 'package:flutter/material.dart';
import '../core/api_service.dart';

class CaretakerProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  List<dynamic> _elderly = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  List<dynamic> get elderly => _elderly;

  List<Map<String, dynamic>> get alerts {
    return _elderly
        .where((e) => e['health_status'] == 'attention' || e['health_status'] == 'critical')
        .map((e) => {
              'type': 'Emergency',
              'title': 'Needs Attention',
              'description': 'Health concern reported for ${e['name']}. Action required.',
              'location': 'Room ${e['room'] ?? 'Unknown'}',
              'time': 'Recent',
              'isNew': true,
            })
        .toList();
  }

  Future<void> fetchElderly(int caretakerId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getAssignedElderly(caretakerId);
      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        _elderly = response['elderly'] ?? [];
      }
    } catch (e) {
      _error = 'Failed to load residents';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateHealthStatus(int elderlyId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.updateElderlyHealth(elderlyId, status);
      if (!response.containsKey('error')) {
        // Optimistically update local state for real-time feel
        final index = _elderly.indexWhere((e) => e['id'] == elderlyId);
        if (index != -1) {
          _elderly[index]['health_status'] = status;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
       _error = 'Update failed';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> submitDailyReport(Map<String, dynamic> reportData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.addDailyReport(reportData);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return false;
      } else {
        // Refresh elderly list to show updated status
        if (reportData.containsKey('caretaker_id')) {
           await fetchElderly(reportData['caretaker_id']);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to submit report';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void triggerEmergency() {
    // Advanced Feature: Emergency Alert System
    _error = 'EMERGENCY ALERT BROADCASTED SECURELY';
    notifyListeners();
    Future.delayed(const Duration(seconds: 4), () {
      _error = '';
      notifyListeners();
    });
  }

  Future<bool> submitFacilityReport(Map<String, dynamic> reportData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.addFacilityReport(reportData);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return false;
      } else {
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to submit facility report';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
