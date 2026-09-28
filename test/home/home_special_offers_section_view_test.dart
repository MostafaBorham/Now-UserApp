import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_special_offers_section_view.dart';

import '../helpers/categories_test_harness.dart';

/// The section holds its slot while the feed loads, so its skeleton must be
/// exactly as tall as the section it turns into — any difference is the jump
/// the skeleton exists to remove.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<double> sectionHeight(
    WidgetTester tester,
    HomeSpecialOffersSectionView section,
  ) async {
    await pumpCategoriesWidget(
      tester,
      // Unbounded height, as in the feed's list, so the section sizes itself.
      SingleChildScrollView(child: section),
    );
    return tester.getSize(find.byType(HomeSpecialOffersSectionView)).height;
  }

  testWidgets('the skeleton is as tall as the loaded section', (
    WidgetTester tester,
  ) async {
    final double skeleton = await sectionHeight(
      tester,
      const HomeSpecialOffersSectionView(isLoading: true),
    );
    final double loaded = await sectionHeight(
      tester,
      const HomeSpecialOffersSectionView(
        offers: <HomeOfferModel>[HomeOfferModel(), HomeOfferModel()],
        topBanners: <BannerModel>[BannerModel(id: 1)],
      ),
    );

    expect(skeleton, greaterThan(0));
    expect(skeleton, moreOrLessEquals(loaded, epsilon: 0.5));
  });

  testWidgets('takes no space once loaded with nothing to show', (
    WidgetTester tester,
  ) async {
    expect(
      await sectionHeight(tester, const HomeSpecialOffersSectionView()),
      0,
    );
  });
}
