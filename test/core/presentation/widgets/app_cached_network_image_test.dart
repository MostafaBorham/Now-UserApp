import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

import '../../../helpers/categories_test_harness.dart';

/// An image with no finite size of its own used to decode at the uploaded
/// resolution; it must decode for the box its parent lays out instead — along
/// the box's longer side only, so the image keeps its own aspect ratio.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<CachedNetworkImage> pumpInBox(
    WidgetTester tester,
    Size box, {
    double? width,
    double? height,
  }) async {
    await pumpCategoriesWidget(
      tester,
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 3),
        child: Center(
          child: SizedBox.fromSize(
            size: box,
            child: AppCachedNetworkImage(
              imageUrl: 'http://x/image.png',
              width: width,
              height: height,
            ),
          ),
        ),
      ),
    );
    return tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
  }

  testWidgets('an infinite size decodes along the box width × DPR', (
    WidgetTester tester,
  ) async {
    final CachedNetworkImage image = await pumpInBox(
      tester,
      const Size(200, 100),
      width: double.infinity,
      height: double.infinity,
    );

    expect(image.memCacheWidth, 600);
    expect(image.memCacheHeight, isNull);
  });

  testWidgets('a tall box decodes along its height instead', (
    WidgetTester tester,
  ) async {
    final CachedNetworkImage image = await pumpInBox(
      tester,
      const Size(100, 200),
    );

    expect(image.memCacheWidth, isNull);
    expect(image.memCacheHeight, 600);
  });
}
