import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/core/ui/icon_registry.dart';

void main() {
  group('IconRegistry.resolve', () {
    test('every registered key resolves to an icon', () {
      for (final key in IconRegistry.keys) {
        expect(IconRegistry.resolve(key), isNotNull, reason: 'key: $key');
      }
    });

    test('an unknown key falls back instead of throwing', () {
      expect(IconRegistry.resolve('no_such_icon'),
          IconRegistry.resolve(IconRegistry.fallbackIconKey));
    });

    test('a null or empty key also falls back', () {
      final fallback = IconRegistry.resolve(IconRegistry.fallbackIconKey);
      expect(IconRegistry.resolve(''), fallback);
    });

    test('hasIcon distinguishes registered from unregistered keys', () {
      expect(IconRegistry.hasIcon('fever'), isTrue);
      expect(IconRegistry.hasIcon('definitely_not_registered'), isFalse);
    });

    test('the fallback key is itself registered', () {
      expect(IconRegistry.hasIcon(IconRegistry.fallbackIconKey), isTrue);
    });
  });

  group('IconRegistry.colorFromHex', () {
    test('decodes an ARGB int', () {
      expect(IconRegistry.colorFromHex(0xFFFF5A47).toARGB32(), 0xFFFF5A47);
    });

    test('null yields the neutral surface colour, not transparent', () {
      final c = IconRegistry.colorFromHex(null);
      expect(c.a, greaterThan(0), reason: 'must stay visible on a light surface');
    });

    test('round-trips through Color.value', () {
      const original = 0xFF12A150;
      expect(IconRegistry.colorFromHex(original).toARGB32(), original);
    });
  });
}
