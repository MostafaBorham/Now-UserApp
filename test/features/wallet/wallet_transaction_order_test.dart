import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_history_item.dart';

import '../../helpers/categories_test_harness.dart';

/// A wallet row about an order shows the order's number and opens its details;
/// a row about an order group (a wallet payment, until semi-final §8 ships)
/// shows neither, because the group's number and uuid mean nothing to the
/// customer.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<void> pumpRow(WidgetTester tester, Map<String, dynamic> reference) {
    return pumpCategoriesScreen(
      tester,
      Scaffold(
        body: WalletHistoryItem(
          transaction: WalletTransactionModel.fromJson(<String, dynamic>{
            'id': 1,
            'title': 'negm',
            'display_status': 'refunded',
            'amount_label': '152.65',
            'reference': reference,
          }),
        ),
      ),
      destinationRoutes: <RouteBase>[
        GoRoute(
          name: AppRoutes.orderDetailsScreen,
          path: '/${AppRoutes.orderDetailsScreen}',
          builder: (BuildContext context, GoRouterState state) =>
              Scaffold(body: Text('details ${state.extra}')),
        ),
      ],
    );
  }

  testWidgets('an order row shows its number and opens its details', (
    tester,
  ) async {
    await pumpRow(tester, <String, dynamic>{
      'type': 'order',
      'id': 7,
      'uuid': 'order-uuid',
      'number': 'RUH-ORD-20261101-ABC123',
    });

    expect(find.text('RUH-ORD-20261101-ABC123'), findsOneWidget);

    await tester.tap(find.text('negm'));
    await tester.pumpAndSettle();

    expect(find.text('details order-uuid'), findsOneWidget);
  });

  testWidgets('an order group row shows no number and ignores taps', (
    tester,
  ) async {
    await pumpRow(tester, <String, dynamic>{
      'type': 'order_group',
      'id': 3,
      'uuid': 'group-uuid',
      'number': 'GRP-2026-00003',
    });

    expect(find.text('GRP-2026-00003'), findsNothing);

    await tester.tap(find.text('negm'));
    await tester.pumpAndSettle();

    expect(find.textContaining('details'), findsNothing);
  });
}
