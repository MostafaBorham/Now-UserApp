import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_live_orders_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/live_order_track_card.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_live_orders_vm.dart';

import '../helpers/categories_test_harness.dart';

/// Live orders frozen at [orders]; no polling.
class _Fixed extends GetLiveOrdersViewModel {
  _Fixed(List<OrderModel> orders) {
    state = AsyncValue<List<OrderModel>>.data(orders);
  }

  @override
  void start() {}
}

// BUG-035: one live order sat off-centre at the strip's 85 % peek width.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('a single order fills the strip between even margins', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      // The test font draws every glyph 1 em wide, and the labels are bare
      // keys; at full size the step row overflows a card no phone would.
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(0.5)),
          child: const HomeLiveOrdersSectionView(),
        ),
      ),
      overrides: <Override>[
        getLiveOrdersProvider.overrideWith(
          (Ref ref) => _Fixed(const <OrderModel>[OrderModel(uuid: 'a')]),
        ),
      ],
    );

    final Rect card = tester.getRect(find.byType(LiveOrderTrackCard));
    final double width = tester.view.physicalSize.width;
    expect(card.left, 10);
    expect(width - card.right, 10);
  });
}
