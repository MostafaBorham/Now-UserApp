import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';

import '../../helpers/categories_test_harness.dart';

/// Only the item-count chip: a raw key is wider than the chip row ever is.
class _KeyLoader extends AssetLoader {
  const _KeyLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{
        LangKeys.itemsCountKey: <String, String>{'other': '{} items'},
      };
}

OrderModel _order(double total) => OrderModel.fromJson(<String, dynamic>{
  'order_number': 'JED-ORD-20261031-0001',
  'status': 'cancelled',
  'total_amount': total,
});

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('a long total stays inside the card, ending where a short one '
      'does', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: LocalizationConstants.supportedLocales,
        path: LocalizationConstants.languagesPath,
        startLocale: LocalizationConstants.englishLocale,
        assetLoader: const _KeyLoader(),
        child: Builder(
          builder: (BuildContext context) => ProviderScope(
            child: MaterialApp(
              theme: AppThemes.getLightModeTheme(),
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              // A phone-width card, as in the my-orders list.
              home: Center(
                child: SizedBox(
                  width: 336,
                  child: Column(
                    children: <Widget>[
                      OrderListItem(orderModel: _order(18161.42)),
                      OrderListItem(orderModel: _order(39.37)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('18161.42'), findsOneWidget);
    for (int i = 0; i < 2; i++) {
      // The card's own 12 px padding is its content's edge.
      expect(
        tester.getTopRight(find.byType(NewPriceWidget).at(i)).dx,
        tester.getTopRight(find.byType(OrderListItem).at(i)).dx - 12,
      );
    }
  });
}
