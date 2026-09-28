import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/svg_tint.dart';

/// `SvgTint` replaces `ColorFilter.mode(color, BlendMode.srcIn)` on single-colour
/// icons: every colour becomes the tint, keeping its own alpha. It must compare
/// by value — flutter_svg keys its parse cache on the mapper, so a mapper that
/// is new every build would re-parse the icon every build.
void main() {
  const Color red = Color(0xFFE53935);

  test('every colour becomes the tint, keeping its own alpha', () {
    const SvgTint tint = SvgTint(red);

    expect(tint.substitute(null, 'path', 'fill', const Color(0xFF000000)), red);
    expect(
      tint.substitute(null, 'path', 'stroke', const Color(0x80123456)).a,
      moreOrLessEquals(0x80 / 0xFF, epsilon: 0.01),
    );
  });

  test('a half-transparent tint stays half-transparent', () {
    final SvgTint tint = SvgTint(red.withValues(alpha: 0.5));

    expect(
      tint.substitute(null, 'path', 'fill', const Color(0xFF000000)).a,
      moreOrLessEquals(0.5, epsilon: 0.01),
    );
  });

  test('equal colours give equal mappers, so the parse is shared', () {
    // Built at run time, as a widget's build does — not two canonical consts.
    final SvgTint a = SvgTint(Color(red.toARGB32()));
    final SvgTint b = SvgTint(Color(red.toARGB32()));

    expect(identical(a, b), isFalse);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const SvgTint(Color(0xFF000000))));
  });
}
