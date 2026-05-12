import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  
  static const String _localIp = '192.168.0.93'; 

  static String get baseUrl {
    // TUNNEL: Your local backend via ngrok
    const String tunnelUrl = 'https://professor-vividness-imminent.ngrok-free.dev/api';
    
    // PRODUCTION: Your Render URL
    const String prodUrl = 'https://saanjh-xl2k.onrender.com/api';
    
    // Set this to true to use the ngrok tunnel (Local Backend)
    const bool useTunnel = true;

    if (useTunnel) return tunnelUrl;
    return prodUrl;
  }

  // HELPER: Handle HTTP Responses consistently
  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        return {'error': decoded['error'] ?? 'Server Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'Failed to parse server response'};
    }
  }

  // HELPER: Handle Exceptions safely
  static Map<String, dynamic> _handleError(dynamic e) {
    print('API Error: $e'); // Print error to console for debugging
    if (e is TimeoutException) {
      return {'error': 'Connection timed out. Server might be down or unreachable on this network.'};
    }
    return {'error': 'Network connection failed. Check server.'};
  }

  // --- AUTH --- //

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Sending login request to: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10)); // Fail-fast timeout
      
      print('Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role, {int? oldAgeHomeId, String? avatarUrl}) async {
    try {
      print('Sending register request to: $baseUrl/auth/register');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name, 
          'email': email, 
          'password': password, 
          'role': role,
          'old_age_home_id': oldAgeHomeId,
          'avatar_url': avatarUrl
        }),
      ).timeout(const Duration(seconds: 10)); // Fail-fast timeout
      
      print('Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- CARETAKER --- //

  static Future<Map<String, dynamic>> getAssignedElderly(int caretakerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/caretaker/$caretakerId/elderly'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateElderlyHealth(int elderlyId, String healthStatus, {String? report}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/caretaker/elderly/$elderlyId/health'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'health_status': healthStatus, 'health_report': report}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> addElderly(String name, int age, String healthStatus, int caretakerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/caretaker/elderly'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'age': age, 'health_status': healthStatus, 'caretaker_id': caretakerId}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> addDailyReport(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/caretaker/daily-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- GOVERNMENT --- //

  static Future<Map<String, dynamic>> getDailyReportsByHome(int homeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/government/reports/$homeId'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getAllElderly() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/government/elderly'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/government/reports'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateHomeStatus(int homeId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/government/homes/$homeId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> submitFeedback(int homeId, int govtId, int rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/government/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'old_age_home_id': homeId,
          'government_id': govtId,
          'rating': rating,
          'comment': comment
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getFeedbackByHome(int homeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/government/homes/$homeId/feedback'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- HOMES --- //

  static Future<List<dynamic>> getAllHomes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/homes'));
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : [];
    } catch (e) {
      print('Error fetching homes: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addHome(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/homes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- ADMIN --- //

  static Future<Map<String, dynamic>> getAllData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/all'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/admin/users/$userId'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> addResident(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/residents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getResidentsByHome(int homeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/residents/$homeId'));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateHomeImage(int homeId, String imageUrl) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/homes/update-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'homeId': homeId, 'image_url': imageUrl}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
}
