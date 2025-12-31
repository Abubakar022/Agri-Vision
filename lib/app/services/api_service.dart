import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxService {
  static const String BASE_URL = "https://agrivision-backend-1075549714370.us-central1.run.app";
  
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? params}) async {
    try {
      final url = Uri.parse('$BASE_URL$endpoint').replace(queryParameters: params);
      final response = await http.get(url);
      return _handleResponse(response);
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$BASE_URL$endpoint');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$BASE_URL$endpoint');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$BASE_URL$endpoint');
      final response = await http.delete(url);
      return _handleResponse(response);
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw data['message'] ?? 'Something went wrong';
    }
  }
}