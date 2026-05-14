import 'package:flutter/material.dart';
import '../core/api_service.dart';

class GovernmentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  List<dynamic> _homes = [];
  int _totalResidents = 0;
  int _highRiskCount = 0;

  List<dynamic> _reports = []; // Home specific reports
  List<dynamic> _feedbacks = []; // Home specific feedbacks
  List<dynamic> _systemAlerts = []; // System wide alerts
  List<dynamic> _facilityReports = []; // Facility wide reports

  bool get isLoading => _isLoading;
  String get error => _error;
  List<dynamic> get homes => _homes;
  List<dynamic> get reports => _reports;
  List<dynamic> get feedbacks => _feedbacks;
  List<dynamic> get systemAlerts => _systemAlerts;
  List<dynamic> get facilityReports => _facilityReports;
  int get totalResidents => _totalResidents;
  int get highRiskCount => _highRiskCount;

  Future<void> fetchHomeData(int homeId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final reportsRes = await ApiService.getDailyReportsByHome(homeId);
      final feedbackRes = await ApiService.getFeedbackByHome(homeId);
      final facilityReportsRes = await ApiService.getFacilityReportsByHome(homeId);

      if (reportsRes.containsKey('error')) {
        _error = reportsRes['error'];
      } else {
        _reports = reportsRes['reports'] ?? [];
      }

      if (feedbackRes.containsKey('error')) {
        // Log error but don't block reports
        print('Feedback error: ${feedbackRes['error']}');
      } else {
        _feedbacks = feedbackRes['feedbacks'] ?? [];
      }

      if (facilityReportsRes.containsKey('error')) {
        print('Facility reports error: ${facilityReportsRes['error']}');
      } else {
        _facilityReports = facilityReportsRes['facility_reports'] ?? [];
      }
    } catch (e) {
      _error = 'Failed to load home data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitHomeFeedback(int homeId, int govtId, int rating, String comment) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.submitFeedback(homeId, govtId, rating, comment);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return false;
      } else {
        // Refresh feedback list
        await fetchHomeData(homeId);
        return true;
      }
    } catch (e) {
      _error = 'Failed to submit feedback';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchDashboardAnalytics() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getAllData();
      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        final elderly = response['elderly'] ?? [];
        _homes = response['homes'] ?? [];
        _totalResidents = elderly.length;
        _highRiskCount = elderly.where((e) => e['health_status']?.toLowerCase() == 'critical').length;
        
        final allDaily = response['daily_reports'] ?? [];
        _systemAlerts = allDaily.where((r) => r['issues'] != null && r['issues'].toString().trim().isNotEmpty).toList();
      }
    } catch (e) {
      _error = 'Failed to load analytics';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHome(Map<String, dynamic> homeData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.addHome({
        'name': homeData['name'],
        'location': homeData['location'],
        'district': homeData['district'],
        'image_url': homeData['image_url'],
      });

      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        // Refresh the list
        await fetchDashboardAnalytics();
      }
    } catch (e) {
      _error = 'Failed to add home';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHomeReports(int homeId) async {
    _isLoading = true;
    _error = '';
    _reports = [];
    notifyListeners();

    try {
      final response = await ApiService.getDailyReportsByHome(homeId);
      if (response.containsKey('error')) {
        _error = response['error'];
      } else {
        _reports = response['reports'] ?? [];
      }
    } catch (e) {
      _error = 'Failed to load reports';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acknowledgeReport(int reportId, String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.acknowledgeReport(reportId, type);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _error = 'Failed to acknowledge report';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> scheduleInspection(int homeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.scheduleInspection(homeId);
      _isLoading = false;
      if (response.containsKey('error')) {
        _error = response['error'];
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _error = 'Failed to schedule inspection';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
