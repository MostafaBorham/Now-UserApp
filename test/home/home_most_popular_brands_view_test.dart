import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_most_popular_brands_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';

import '../helpers/categories_test_harness.dart';

class _FakeFeatured extends GetFeaturedStoresViewModel {
  _FakeFeatured(List<StoreModel> stores) {
    state = AsyncValue<PaginationModel<StoreModel>>.data(
      pageOf<StoreModel>(stores),
    );
  }

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) =>
      throw UnimplementedError();
}

/// BUG-024 (QA V2): two rows fill column by column, so one or two brands left
/// an empty cell or stacked in the first column.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<void> pumpBrands(WidgetTester tester, int count) =>
      pumpCategoriesWidget(
        tester,
        const HomeMostPopularBrandsView(),
        overrides: <Override>[
          getFeaturedStoresProvider.overrideWith(
            (Ref ref) => _FakeFeatured(<StoreModel>[
              for (int i = 0; i < count; i++)
                sampleStore(id: i + 1, en: 'Brand $i'),
            ]),
          ),
        ],
      );

  testWidgets('two brands sit side by side in one row', (tester) async {
    await pumpBrands(tester, 2);

    final double first = tester.getTopLeft(find.text('Brand 0')).dy;
    final double second = tester.getTopLeft(find.text('Brand 1')).dy;
    expect(second, first);
    expect(
      tester.getTopLeft(find.text('Brand 1')).dx,
      isNot(tester.getTopLeft(find.text('Brand 0')).dx),
    );
  });

  testWidgets('three brands use two rows', (tester) async {
    await pumpBrands(tester, 3);

    expect(
      tester.getTopLeft(find.text('Brand 1')).dy,
      greaterThan(tester.getTopLeft(find.text('Brand 0')).dy),
    );
  });
}
