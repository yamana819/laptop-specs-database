import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cpu.dart';
import '../utils/api_config.dart';

class CpuService {
  static String get baseUrl => '${ApiConfig.baseUrl}/cpus';

  Future<List<Cpu>> getAllCpus() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((item) => Cpu.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load CPU list: ${response.statusCode}');
    }
  }

  Future<Cpu> createCpu(Cpu cpu) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cpu.toJson()),
    );
    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Cpu.fromJson(data);
    } else {
      throw Exception('Failed to create CPU: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Cpu> updateCpu(int id, Cpu cpu) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cpu.toJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Cpu.fromJson(data);
    } else {
      throw Exception('Failed to update CPU: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteCpu(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete CPU: ${response.statusCode}');
    }
  }
}
