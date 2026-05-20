class Gpu {
  final int id;
  final String brand;
  final String modelName;
  final int? tdpWatt;
  final int? vramGb;
  final String? vramType;
  final int? memoryBusBit;

  Gpu({
    required this.id,
    required this.brand,
    required this.modelName,
    this.tdpWatt,
    this.vramGb,
    this.vramType,
    this.memoryBusBit,
  });

  factory Gpu.fromJson(Map<String, dynamic> json) {
    return Gpu(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      modelName: json['modelName'] ?? '',
      tdpWatt: json['tdpWatt'],
      vramGb: json['vramGb'],
      vramType: json['vramType'],
      memoryBusBit: json['memoryBusBit'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'brand': brand,
      'modelName': modelName,
    };
    if (tdpWatt != null) map['tdpWatt'] = tdpWatt;
    if (vramGb != null) map['vramGb'] = vramGb;
    if (vramType != null) map['vramType'] = vramType;
    if (memoryBusBit != null) map['memoryBusBit'] = memoryBusBit;
    return map;
  }

  String get displayLabel => '$brand $modelName${vramGb != null ? ' ${vramGb}GB' : ''}';
}
