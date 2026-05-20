import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gpu.dart';
import '../utils/api_config.dart';

class GpuService {
  static String get baseUrl => '${ApiConfig.baseUrl}/gpus';

  Future<List<Gpu>> getAllGpus() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((item) => Gpu.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load GPU list: ${response.statusCode}');
    }
  }

  Future<Gpu> createGpu(Gpu gpu) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(gpu.toJson()),
    );
    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Gpu.fromJson(data);
    } else {
      throw Exception('Failed to create GPU: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Gpu> updateGpu(int id, Gpu gpu) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(gpu.toJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Gpu.fromJson(data);
    } else {
      throw Exception('Failed to update GPU: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteGpu(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete GPU: ${response.statusCode}');
    }
  }
}
