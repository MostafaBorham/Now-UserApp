import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/header_intro_animations.dart';

/// The header intros replay the SVGs' CSS keyframes. The last line ("will
/// arrive in 15 minutes") is hidden until 54.17%, eases in by 58.33%, and —
/// the SVG's `forwards` fill — holds after the 12 s run.
void main() {
  final Animatable<double> lastLine =
      QuickDeliveryAnimation.imageOpacities.last;

  test('the last line is hidden at 50%', () {
    expect(lastLine.transform(0.5), 0);
  });

  test('it is fully shown at 60% and stays shown at the end', () {
    expect(lastLine.transform(0.6), 1);
    expect(lastLine.transform(1.0), 1);
  });

  test('it eases between its keyframes', () {
    // Halfway through 54.17%→58.33% on CSS `ease` is past the linear midpoint.
    expect(lastLine.transform(0.5625), greaterThan(0.5));
    expect(lastLine.transform(0.5625), lessThan(1));
  });
}
