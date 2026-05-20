class Cpu {
  final int id;
  final String brand;
  final String series;
  final String modelName;
  final double baseClockGhz;
  final double? boostClockGhz;
  final int coreCount;
  final int threadCount;
  final int cacheMb;

  Cpu({
    required this.id,
    required this.brand,
    required this.series,
    required this.modelName,
    required this.baseClockGhz,
    this.boostClockGhz,
    required this.coreCount,
    required this.threadCount,
    required this.cacheMb,
  });

  factory Cpu.fromJson(Map<String, dynamic> json) {
    return Cpu(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      series: json['series'] ?? '',
      modelName: json['modelName'] ?? '',
      baseClockGhz: (json['baseClockGhz'] ?? 0).toDouble(),
      boostClockGhz: json['boostClockGhz'] != null
          ? (json['boostClockGhz']).toDouble()
          : null,
      coreCount: json['coreCount'] ?? 0,
      threadCount: json['threadCount'] ?? 0,
      cacheMb: json['cacheMb'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'brand': brand,
      'series': series,
      'modelName': modelName,
      'baseClockGhz': baseClockGhz,
      'coreCount': coreCount,
      'threadCount': threadCount,
      'cacheMb': cacheMb,
    };
    if (boostClockGhz != null) map['boostClockGhz'] = boostClockGhz;
    return map;
  }

  String get displayLabel => '$brand $series $modelName';
}
