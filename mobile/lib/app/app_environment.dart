import 'package:flutter/foundation.dart';

/// Runtime environment configuration.
///
/// Values are baked in at build time via `--dart-define`.
/// No API key is embedded — authentication is handled server-side.
@immutable
class AppEnvironment {
  final String apiBaseUrl;
  final bool isRelease;

  const AppEnvironment._({
    required this.apiBaseUrl,
    required this.isRelease,
  });

  /// Reads build-time defines injected by `flutter build --dart-define=...`.
  ///
  /// Example:
  ///   flutter build apk --dart-define=KURAMA_API_BASE_URL=https://api.kurama.app
  factory AppEnvironment.fromBuildConfig() {
    const apiBaseUrl = String.fromEnvironment(
      'KURAMA_API_BASE_URL',
      defaultValue: '',
    );
    return const AppEnvironment._(
      apiBaseUrl: apiBaseUrl,
      isRelease: kReleaseMode,
    );
  }

  /// Constructor for tests.
  factory AppEnvironment.test({String apiBaseUrl = 'http://localhost:8000'}) {
    return AppEnvironment._(apiBaseUrl: apiBaseUrl, isRelease: false);
  }

  /// True when the API base URL has been configured (non-empty).
  bool get isApiConfigured => apiBaseUrl.isNotEmpty;

  @override
  String toString() =>
      'AppEnvironment(apiBaseUrl: $apiBaseUrl, isRelease: $isRelease)';
}
