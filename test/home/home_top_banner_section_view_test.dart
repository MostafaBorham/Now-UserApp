import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_banner_section_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_header_banners_vm.dart';

import '../helpers/categories_test_harness.dart';






void main() {
  setUpAll(initCategoriesTestLocalization);



  const BannerModel bannerNoImage = BannerModel(id: 1);

  Future<void> pumpSection(
    WidgetTester tester,
    AsyncValue<List<BannerModel>> state,
  ) => pumpCategoriesWidget(
    tester,
    const HomeTopBannerSectionView(),
    overrides: <Override>[
      getHeaderBannersProvider.overrideWith(
        (Ref ref) => _FakeHeaderBannersVM(state),
      ),
    ],
  );

  testWidgets('renders the banner on the design 355×118 box', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      const AsyncValue<List<BannerModel>>.data(<BannerModel>[bannerNoImage]),
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
      const AsyncValue<List<BannerModel>>.loading(),
    );

    final Finder skeleton = find.byType(AspectRatio);
    expect(tester.getSize(skeleton).width, moreOrLessEquals(355, epsilon: 0.5));
    expect(
      tester.getSize(skeleton).height,
      moreOrLessEquals(118, epsilon: 0.5),
    );
  });

  testWidgets('takes no space with no banners', (WidgetTester tester) async {
    await pumpSection(
      tester,
      const AsyncValue<List<BannerModel>>.data(<BannerModel>[]),
    );

    expect(find.byType(AppCachedNetworkImage), findsNothing);
  });
}

class _FakeHeaderBannersVM extends GetHeaderBannersViewModel {
  _FakeHeaderBannersVM(AsyncValue<List<BannerModel>> initial) {
    state = initial;
  }

  @override
  Future<void> getHeaderBanners() async {}
}
