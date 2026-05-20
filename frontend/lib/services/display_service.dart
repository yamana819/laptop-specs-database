import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/display.dart';
import '../utils/api_config.dart';

class DisplayService {
  static String get baseUrl => '${ApiConfig.baseUrl}/displays';

  Future<List<Display>> getAllDisplays() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((item) => Display.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load display list: ${response.statusCode}');
    }
  }

  Future<Display> createDisplay(Display display) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(display.toJson()),
    );
    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Display.fromJson(data);
    } else {
      throw Exception('Failed to create display: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Display> updateDisplay(int id, Display display) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(display.toJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Display.fromJson(data);
    } else {
      throw Exception('Failed to update display: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteDisplay(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete display: ${response.statusCode}');
    }
  }
}
