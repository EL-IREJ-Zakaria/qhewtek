import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get apiBaseUrl {
    final configuredApiBaseUrl = _normalizeApiBaseUrl(_configuredApiBaseUrl);
    if (configuredApiBaseUrl != null) {
      return configuredApiBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api';
      default:
        return 'http://127.0.0.1:8000/api';
    }
  }

  static String get backendBaseUrl => apiBaseUrl.replaceFirst('/api', '');

  static String? _normalizeApiBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final withoutTrailingSlash = trimmed.replaceFirst(RegExp(r'/+$'), '');
    if (withoutTrailingSlash.endsWith('/api')) {
      return withoutTrailingSlash;
    }

    return '$withoutTrailingSlash/api';
  }
}
