import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/jobhub_model.dart';

class JobhubService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const Map<String, String> _headers = ApiConfig.defaultHeaders;

  // Get all jobhubs
  static Future<List<JobhubModel>> getAllJobhubs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => JobhubModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobhubs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobhubs: $e');
    }
  }

  // Get jobhub by ID
  static Future<JobhubModel> getJobhubById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return JobhubModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load jobhub: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobhub: $e');
    }
  }

  // Get available jobhubs (status = 1)
  static Future<List<JobhubModel>> getAvailableJobhubs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}?filter[where][jobStatus]=1'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => JobhubModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load available jobhubs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching available jobhubs: $e');
    }
  }

  // Get active jobhubs (status = 2)
  static Future<List<JobhubModel>> getActiveJobhubs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}?filter[where][jobStatus]=2'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => JobhubModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load active jobhubs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching active jobhubs: $e');
    }
  }

  // Get jobhubs by category
  static Future<List<JobhubModel>> getJobhubsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}?filter[where][category]=$category'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => JobhubModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobhubs by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobhubs by category: $e');
    }
  }

  // Create new jobhub
  static Future<JobhubModel> createJobhub(JobhubModel jobhub) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}'),
        headers: _headers,
        body: json.encode(jobhub.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return JobhubModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to create jobhub: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating jobhub: $e');
    }
  }

  // Update jobhub
  static Future<void> updateJobhub(int id, JobhubModel jobhub) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}/$id'),
        headers: _headers,
        body: json.encode(jobhub.toJson()),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update jobhub: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating jobhub: $e');
    }
  }

  // Delete jobhub
  static Future<void> deleteJobhub(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}/$id'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete jobhub: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting jobhub: $e');
    }
  }

  // Get jobhub count
  static Future<int> getJobhubCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobhubEndpoint}/count'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['count'] ?? 0;
      } else {
        throw Exception('Failed to get jobhub count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting jobhub count: $e');
    }
  }
}
