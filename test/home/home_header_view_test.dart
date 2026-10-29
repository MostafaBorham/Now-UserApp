import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_header_view.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  setUpAll(() async {
    await initCategoriesTestLocalization();
    await SharedPrefManager.init();
  });

  Finder svg(String asset) => find.byWidgetPredicate(
    (Widget w) =>
        w is SvgPicture &&
        w.bytesLoader is SvgAssetLoader &&
        (w.bytesLoader as SvgAssetLoader).assetName == asset,
  );

  // A notch's tall status bar pushed the logo row down while the green shape
  // stayed put, so the logo sat on the shape's bottom edge (realme C35).
  testWidgets('the shape moves down with a taller status bar', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPadding);

    Future<double> logoBelowShapeTop(double statusBar) async {
      tester.view.padding = FakeViewPadding(top: statusBar);
      await pumpCategoriesWidget(
        tester,
        const SingleChildScrollView(
          child: HomeHeaderView(showCategories: false),
        ),
      );
      final Rect art = tester.getRect(
        svg(Assets.media.images.svg.homeHeaderBackground.path),
      );
      final Rect logo = tester.getRect(
        svg(Assets.media.images.svg.appLogos.homeWhiteAppLogo.path),
      );
      // The shape is the art's bottom 457 of 390 wide; above it is headroom.
      return logo.top - (art.bottom - art.width * 457 / 390);
    }

    final double short = await logoBelowShapeTop(24);
    expect(await logoBelowShapeTop(50), short);
  });
}
