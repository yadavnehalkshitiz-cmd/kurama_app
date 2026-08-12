import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurama_mobile/app/theme/kurama_colors.dart';
import 'package:kurama_mobile/app/theme/kurama_theme.dart';

void main() {
  group('buildKuramaTheme', () {
    test('uses Material 3 dark theme with KuramaColors', () {
      final theme = buildKuramaTheme();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(KuramaColors.ink));
      expect(theme.colorScheme.primary, equals(KuramaColors.lacquer));
      expect(theme.colorScheme.secondary, equals(KuramaColors.gold));
    });

    test('enforces minimum touch targets of 48dp on filled buttons', () {
      final theme = buildKuramaTheme();
      final minSize = theme.filledButtonTheme.style?.minimumSize?.resolve({});
      expect(minSize?.height, greaterThanOrEqualTo(48.0));
    });
  });
}
