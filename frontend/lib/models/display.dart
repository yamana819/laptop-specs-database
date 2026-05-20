class Display {
  final int id;
  final double sizeInch;
  final String resolution;
  final int refreshRateHz;
  final String panelType;
  final int? brightnessNits;

  Display({
    required this.id,
    required this.sizeInch,
    required this.resolution,
    required this.refreshRateHz,
    required this.panelType,
    this.brightnessNits,
  });

  factory Display.fromJson(Map<String, dynamic> json) {
    return Display(
      id: json['id'] ?? 0,
      sizeInch: (json['sizeInch'] ?? 0).toDouble(),
      resolution: json['resolution'] ?? '',
      refreshRateHz: json['refreshRateHz'] ?? 0,
      panelType: json['panelType'] ?? '',
      brightnessNits: json['brightnessNits'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'sizeInch': sizeInch,
      'resolution': resolution,
      'refreshRateHz': refreshRateHz,
      'panelType': panelType,
    };
    if (brightnessNits != null) map['brightnessNits'] = brightnessNits;
    return map;
  }

  String get displayLabel =>
      '${sizeInch}" $resolution ${refreshRateHz}Hz $panelType';
}
