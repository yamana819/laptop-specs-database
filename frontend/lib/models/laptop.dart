class Laptop {
  final int id;
  final String brand;
  final String series;

  final String cpuBrand;
  final String cpuSeries;
  final String cpuModelName;
  final int cpuCoreCount;
  final int cpuThreadCount;
  final int cpuCacheMb;
  final double cpuBaseClockGhz;
  final double? cpuBoostClockGhz;

  final String gpuBrand;
  final String gpuModelName;
  final int? gpuTdpWatt;
  final int? gpuVramGb;
  final String? gpuVramType;
  final int? gpuMemoryBusBit;

  final double displaySizeInch;
  final String displayResolution;
  final int displayRefreshRateHz;
  final String displayPanelType;
  final int? displayBrightnessNits;

  final int ramCapacityGb;
  final int ramSpeedMhz;
  final String ramType;

  final int storageCapacityGb;
  final String storageType;

  final double? weightKg;
  final double thicknessMm;
  final int batteryWh;
  final String? wifiVersion;
  final String? bluetoothVersion;

  Laptop({
    required this.id,
    required this.brand,
    required this.series,
    required this.cpuBrand,
    required this.cpuSeries,
    required this.cpuModelName,
    required this.cpuCoreCount,
    required this.cpuThreadCount,
    required this.cpuCacheMb,
    required this.cpuBaseClockGhz,
    this.cpuBoostClockGhz,
    required this.gpuBrand,
    required this.gpuModelName,
    this.gpuTdpWatt,
    this.gpuVramGb,
    this.gpuVramType,
    this.gpuMemoryBusBit,
    required this.displaySizeInch,
    required this.displayResolution,
    required this.displayRefreshRateHz,
    required this.displayPanelType,
    this.displayBrightnessNits,
    required this.ramCapacityGb,
    required this.ramSpeedMhz,
    required this.ramType,
    required this.storageCapacityGb,
    required this.storageType,
    this.weightKg,
    required this.thicknessMm,
    required this.batteryWh,
    this.wifiVersion,
    this.bluetoothVersion,
  });

  factory Laptop.fromJson(Map<String, dynamic> json) {
    return Laptop(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      series: json['series'] ?? '',
      cpuBrand: json['cpuBrand'] ?? '',
      cpuSeries: json['cpuSeries'] ?? '',
      cpuModelName: json['cpuModelName'] ?? '',
      cpuCoreCount: json['cpuCoreCount'] ?? 0,
      cpuThreadCount: json['cpuThreadCount'] ?? 0,
      cpuCacheMb: json['cpuCacheMb'] ?? 0,
      cpuBaseClockGhz: (json['cpuBaseClockGhz'] ?? 0).toDouble(),
      cpuBoostClockGhz: json['cpuBoostClockGhz'] != null
          ? (json['cpuBoostClockGhz']).toDouble()
          : null,
      gpuBrand: json['gpuBrand'] ?? '',
      gpuModelName: json['gpuModelName'] ?? '',
      gpuTdpWatt: json['gpuTdpWatt'],
      gpuVramGb: json['gpuVramGb'],
      gpuVramType: json['gpuVramType'],
      gpuMemoryBusBit: json['gpuMemoryBusBit'],
      displaySizeInch: (json['displaySizeInch'] ?? 0).toDouble(),
      displayResolution: json['displayResolution'] ?? '',
      displayRefreshRateHz: json['displayRefreshRateHz'] ?? 0,
      displayPanelType: json['displayPanelType'] ?? '',
      displayBrightnessNits: json['displayBrightnessNits'],
      ramCapacityGb: json['ramCapacityGb'] ?? 0,
      ramSpeedMhz: json['ramSpeedMhz'] ?? 0,
      ramType: json['ramType'] ?? '',
      storageCapacityGb: json['storageCapacityGb'] ?? 0,
      storageType: json['storageType'] ?? '',
      weightKg: json['weightKg'] != null
          ? (json['weightKg']).toDouble()
          : null,
      thicknessMm: (json['thicknessMm'] ?? 0).toDouble(),
      batteryWh: json['batteryWh'] ?? 0,
      wifiVersion: json['wifiVersion'],
      bluetoothVersion: json['bluetoothVersion'],
    );
  }
}

class LaptopRequest {
  final String brand;
  final String series;
  final int cpuId;
  final int gpuId;
  final int displayId;
  final int ramCapacityGb;
  final int ramSpeedMhz;
  final String ramType;
  final int storageCapacityGb;
  final String storageType;
  final double? weightKg;
  final double thicknessMm;
  final int batteryWh;
  final String? wifiVersion;
  final String? bluetoothVersion;

  LaptopRequest({
    required this.brand,
    required this.series,
    required this.cpuId,
    required this.gpuId,
    required this.displayId,
    required this.ramCapacityGb,
    required this.ramSpeedMhz,
    required this.ramType,
    required this.storageCapacityGb,
    required this.storageType,
    this.weightKg,
    required this.thicknessMm,
    required this.batteryWh,
    this.wifiVersion,
    this.bluetoothVersion,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'brand': brand,
      'series': series,
      'cpuId': cpuId,
      'gpuId': gpuId,
      'displayId': displayId,
      'ramCapacityGb': ramCapacityGb,
      'ramSpeedMhz': ramSpeedMhz,
      'ramType': ramType,
      'storageCapacityGb': storageCapacityGb,
      'storageType': storageType,
      'thicknessMm': thicknessMm,
      'batteryWh': batteryWh,
    };
    if (weightKg != null) map['weightKg'] = weightKg;
    if (wifiVersion != null) map['wifiVersion'] = wifiVersion;
    if (bluetoothVersion != null) map['bluetoothVersion'] = bluetoothVersion;
    return map;
  }
}