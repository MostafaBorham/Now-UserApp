import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';

import '../../../../helpers/categories_test_harness.dart';

/// The store page's offer slider gives each page a fixed height. A product
/// with a rating, a deal and a full description made the details card tall
/// enough to overflow that page by 55 dp; the image now gives up the height.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('a tall card shortens the image instead of overflowing', (
    WidgetTester tester,
  ) async {
    const Key image = Key('image');
    await pumpCategoriesWidget(
      tester,
      AppArrowSlider(
        itemCount: 2,
        itemHeight: 600,
        sliderSpace: 0,
        sliderItemBuilder: (_, _) => const AspectRatio(
          aspectRatio: 1.3,
          child: ColoredBox(key: image, color: Colors.red),
        ),
        aboveImageBuilder: (_, _) => const SizedBox(height: 65),
        belowImageBuilder: (_, _) => const SizedBox(height: 400),
      ),
    );

    expect(tester.takeException(), isNull);
    // 600 - 65 - 400 - two 20 dp gaps.
    expect(tester.getSize(find.byKey(image).first).height, 95);
  });
}
