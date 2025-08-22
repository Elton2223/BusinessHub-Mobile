import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class ApiService {
  static final String baseUrl = EnvConfig.apiBaseUrl;
  static final int timeout = EnvConfig.apiTimeout;

  // Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authorization token
  static Map<String, String> _authHeaders(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  // Generic GET request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _authHeaders(token) : _headers;
    
    print('Making GET request to: $url');
    print('Base URL: $baseUrl');
    print('Endpoint: $endpoint');
    print('Full URL: $url');
    print('Headers: $headers');
    print('Timeout: ${timeout} seconds');
    
    try {
      final response = await http.get(url, headers: headers)
          .timeout(Duration(seconds: timeout));
      
      print('Response received: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } on TimeoutException {
      print('GET request timed out after ${timeout} seconds');
      throw ApiException(
        statusCode: 408,
        message: 'Request timed out. Please check your internet connection and try again.',
      );
    } catch (e) {
      print('GET request failed: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('SocketException')) {
        print('This is a network connectivity issue');
        throw ApiException(
          statusCode: 0,
          message: 'Unable to connect to server. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  // Generic POST request
  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _authHeaders(token) : _headers;
    
    try {
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(Duration(seconds: timeout));
    } on TimeoutException {
      print('POST request timed out after ${timeout} seconds');
      throw ApiException(
        statusCode: 408,
        message: 'Request timed out. Please check your internet connection and try again.',
      );
    } catch (e) {
      print('POST request failed: $e');
      if (e.toString().contains('SocketException')) {
        throw ApiException(
          statusCode: 0,
          message: 'Unable to connect to server. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  // Generic PUT request
  static Future<http.Response> put(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _authHeaders(token) : _headers;
    
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    ).timeout(Duration(seconds: timeout));
  }

  // Generic DELETE request
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = token != null ? _authHeaders(token) : _headers;
    
    return await http.delete(url, headers: headers)
        .timeout(Duration(seconds: timeout));
  }

  // Handle API response
  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'HTTP ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']?['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
      );
    }
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}
