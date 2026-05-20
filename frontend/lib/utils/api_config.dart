import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    
    // Android emulator connects to the host machine via 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    
    // iOS simulator and desktop apps connect via localhost
    return 'http://localhost:8080/api/v1';
  }
}
