import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  // My Addresses and Discount Codes hand the list a controller, which stops it
  // being scrollable (and so pullable) while it is shorter than the screen.
  testWidgets('a short list with a controller can still be pulled to refresh', (
    WidgetTester tester,
  ) async {
    final Provider<AsyncValue<PaginationModel<int>>> provider = Provider(
      (Ref ref) => const AsyncValue<PaginationModel<int>>.data(
        PaginationModel<int>(
          currentPage: 1,
          lastPage: 1,
          perPage: 15,
          total: 1,
          hasMore: false,
          data: <int>[1],
        ),
      ),
    );
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    int refreshes = 0;

    await pumpCategoriesWidget(
      tester,
      PaginatedView<int>(
        provider: provider,
        scrollController: controller,
        onRefresh: () async => refreshes++,
        onLoadNextPage: () {},
        layout: const PaginatedListLayout(),
        placeholderBuilder: (BuildContext context) => const SizedBox(),
        itemBuilder: (BuildContext context, int item, int index) =>
            Text('item $item'),
      ),
    );

    await tester.fling(find.text('item 1'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(refreshes, 1);
  });
}
