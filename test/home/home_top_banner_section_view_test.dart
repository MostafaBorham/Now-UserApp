import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_banner_section_view.dart';

import '../helpers/categories_test_harness.dart';

/// Geometry check for the home top banner. `HomeTopBannerSectionView` has to
/// back `AppSlider`'s per-item padding out of both the side margin and the
/// carousel's aspect ratio to land on the Figma box (355×118 inset 17.5px on a
/// 390pt screen — node 7137:26468), so assert the rendered result, not the
/// arithmetic.
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// A banner with no artwork: `AppCachedNetworkImage` short-circuits an empty
  /// URL to its error placeholder, which fills the box without any network.
  const BannerModel bannerNoImage = BannerModel(id: 1);

  Future<void> pumpSection(
    WidgetTester tester,
    HomeTopBannerSectionView section,
  ) async {
    await pumpCategoriesWidget(
      tester,
      // Unbounded height, as in the feed's list, so the section sizes itself.
      SingleChildScrollView(child: section),
    );
    // Let the 600 ms entrance slide finish, so the banner is measured where it
    // comes to rest.
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('renders the banner on the design 355×118 box', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      const HomeTopBannerSectionView(banners: <BannerModel>[bannerNoImage]),
    );

    final Finder banner = find.byType(AppCachedNetworkImage);
    expect(tester.getSize(banner).width, moreOrLessEquals(355, epsilon: 0.5));
    expect(tester.getSize(banner).height, moreOrLessEquals(118, epsilon: 0.5));
    expect(
      tester.getTopLeft(banner).dx,
      moreOrLessEquals(17.5, epsilon: 0.5),
    );
  });

  testWidgets('the loading skeleton occupies the same box', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      const HomeTopBannerSectionView(isLoading: true),
    );

    final Finder skeleton = find.byType(AspectRatio);
    expect(tester.getSize(skeleton).width, moreOrLessEquals(355, epsilon: 0.5));
    expect(
      tester.getSize(skeleton).height,
      moreOrLessEquals(118, epsilon: 0.5),
    );
  });

  testWidgets('the skeleton is as tall as the carousel that replaces it', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      const HomeTopBannerSectionView(isLoading: true),
    );
    final double skeletonHeight = tester
        .getSize(find.byType(HomeTopBannerSectionView))
        .height;

    await pumpSection(
      tester,
      const HomeTopBannerSectionView(banners: <BannerModel>[bannerNoImage]),
    );

    expect(
      tester.getSize(find.byType(HomeTopBannerSectionView)).height,
      moreOrLessEquals(skeletonHeight, epsilon: 0.5),
    );
  });

  testWidgets('takes no space with no banners', (WidgetTester tester) async {
    await pumpSection(tester, const HomeTopBannerSectionView());

    expect(find.byType(AppCachedNetworkImage), findsNothing);
  });
}
