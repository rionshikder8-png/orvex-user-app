import 'package:flutter_test/flutter_test.dart';
import 'package:orvex_user_app/core/strings_bn.dart';
import 'package:orvex_user_app/core/strings_en.dart';

void main() {
  test('English and Bangla tables have identical keys', () {
    final en = stringsEn.keys.toSet();
    final bn = stringsBn.keys.toSet();
    expect(en.difference(bn), isEmpty, reason: 'missing in Bangla');
    expect(bn.difference(en), isEmpty, reason: 'missing in English');
  });

  test('no translation value is empty', () {
    for (final e in [...stringsEn.entries, ...stringsBn.entries]) {
      expect(e.value.trim(), isNotEmpty, reason: e.key);
    }
  });

  test('placeholders match between languages', () {
    final re = RegExp(r'\{(\w+)\}');
    for (final k in stringsEn.keys) {
      final a = re.allMatches(stringsEn[k]!).map((m) => m.group(1)).toSet();
      final b = re.allMatches(stringsBn[k]!).map((m) => m.group(1)).toSet();
      expect(a, b, reason: 'placeholder mismatch in "$k"');
    }
  });
}
