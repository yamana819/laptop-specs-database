import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/laptop.dart';
import '../models/paged_response.dart';
import '../utils/api_config.dart';

class LaptopService {
  static String get baseUrl => '${ApiConfig.baseUrl}/laptops';

  Future<PagedResponse<Laptop>> getLaptops({
    int page = 0,
    int size = 100,
    String sortBy = 'id',
    String sortDir = 'asc',
    String? brand,
    String? series,
    String? gpuBrand,
    int? minVramGb,
    String? cpuBrand,
    String? cpuSeries,
    int? minCoreCount,
    int? minRamGb,
    int? maxRamGb,
    String? ramType,
    int? minStorageGb,
    String? storageType,
    double? minDisplayInch,
    double? maxDisplayInch,
    int? minRefreshRateHz,
    String? resolution,
    String? panelType,
    double? maxWeightKg,
    int? minBatteryWh,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'size': '$size',
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (brand != null && brand.isNotEmpty) params['brand'] = brand;
    if (series != null && series.isNotEmpty) params['series'] = series;
    if (gpuBrand != null && gpuBrand.isNotEmpty) params['gpuBrand'] = gpuBrand;
    if (minVramGb != null) params['minVramGb'] = '$minVramGb';
    if (cpuBrand != null && cpuBrand.isNotEmpty) params['cpuBrand'] = cpuBrand;
    if (cpuSeries != null && cpuSeries.isNotEmpty) params['cpuSeries'] = cpuSeries;
    if (minCoreCount != null) params['minCoreCount'] = '$minCoreCount';
    if (minRamGb != null) params['minRamGb'] = '$minRamGb';
    if (maxRamGb != null) params['maxRamGb'] = '$maxRamGb';
    if (ramType != null && ramType.isNotEmpty) params['ramType'] = ramType;
    if (minStorageGb != null) params['minStorageGb'] = '$minStorageGb';
    if (storageType != null && storageType.isNotEmpty) params['storageType'] = storageType;
    if (minDisplayInch != null) params['minDisplayInch'] = '$minDisplayInch';
    if (maxDisplayInch != null) params['maxDisplayInch'] = '$maxDisplayInch';
    if (minRefreshRateHz != null) params['minRefreshRateHz'] = '$minRefreshRateHz';
    if (resolution != null && resolution.isNotEmpty) params['resolution'] = resolution;
    if (panelType != null && panelType.isNotEmpty) params['panelType'] = panelType;
    if (maxWeightKg != null) params['maxWeightKg'] = '$maxWeightKg';
    if (minBatteryWh != null) params['minBatteryWh'] = '$minBatteryWh';

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PagedResponse.fromJson(data, (json) => Laptop.fromJson(json));
    } else {
      throw Exception('Failed to load laptops: ${response.statusCode}');
    }
  }

  Future<Laptop> getLaptopById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Laptop.fromJson(data);
    } else {
      throw Exception('Laptop not found: ${response.statusCode}');
    }
  }

  Future<Laptop> createLaptop(LaptopRequest request) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Laptop.fromJson(data);
    } else {
      throw Exception('Failed to create laptop: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Laptop> updateLaptop(int id, LaptopRequest request) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return Laptop.fromJson(data);
    } else {
      throw Exception('Failed to update laptop: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteLaptop(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete laptop: ${response.statusCode}');
    }
  }

  Future<List<String>> getBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/meta/brands'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load brands: ${response.statusCode}');
    }
  }

  Future<List<String>> getGpuModels() async {
    final response = await http.get(Uri.parse('$baseUrl/meta/gpu-models'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load GPU models: ${response.statusCode}');
    }
  }
}