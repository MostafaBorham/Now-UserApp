import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/utils/color_sharpener.dart';

void main() {
  test('a light tint comes back dark enough to read as text', () {
    final HSLColor sharp = HSLColor.fromColor(
      sharpenColor(const Color(0x80A8C8F0)),
    );

    // 0.35, give or take the 8-bit rounding of the channels.
    expect(sharp.lightness, lessThan(0.36));
    expect(sharp.alpha, 1);
  });

  test('a grey stays grey', () {
    final HSLColor sharp = HSLColor.fromColor(
      sharpenColor(const Color(0xFFBDBDBD)),
    );

    expect(sharp.saturation, 0);
  });
}
