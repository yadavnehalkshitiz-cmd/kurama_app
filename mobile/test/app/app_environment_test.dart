import 'package:flutter_test/flutter_test.dart';
import 'package:kurama_mobile/app/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('fromBuildConfig defaults to empty apiBaseUrl when dart-define is absent', () {
      final env = AppEnvironment.fromBuildConfig();
      expect(env.apiBaseUrl, equals(''));
      expect(env.isApiConfigured, isFalse);
    });

    test('AppEnvironment.test provides test defaults', () {
      final env = AppEnvironment.test(apiBaseUrl: 'http://127.0.0.1:8000');
      expect(env.apiBaseUrl, equals('http://127.0.0.1:8000'));
      expect(env.isApiConfigured, isTrue);
      expect(env.isRelease, isFalse);
    });
  });
}
