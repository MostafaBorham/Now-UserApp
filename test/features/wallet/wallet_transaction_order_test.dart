import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_history_item.dart';

import '../../helpers/categories_test_harness.dart';

/// A wallet row about an order shows the order's number and opens its details.
/// A row about an order group never shows the group's number or opens its uuid
/// (both mean nothing to the customer); when the backend lists the group's
/// orders, a tap lets the customer pick one.
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

  testWidgets('a store row says what it is before the order number', (
    tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      Scaffold(
        body: Column(
          children: <Widget>[
            for (final Map<String, dynamic> json in <Map<String, dynamic>>[
              <String, dynamic>{
                'source': 'order_payment',
                'title': 'negm',
                'merchant': <String, dynamic>{'type': 'vendor'},
                'reference': <String, dynamic>{
                  'type': 'order',
                  'uuid': 'u',
                  'number': 'ORD-1',
                },
              },
              // Not yet flattened to its order (semi-final §8): label alone.
              <String, dynamic>{
                'source': 'order_payment',
                'title': 'negm',
                'merchant': <String, dynamic>{'type': 'vendor'},
                'reference': <String, dynamic>{
                  'type': 'order_group',
                  'uuid': 'g',
                  'number': 'GRP-1',
                },
              },
              // Already titled by its source: no repeat underneath.
              <String, dynamic>{
                'source': 'topup',
                'title': 'Wallet top-up',
                'merchant': <String, dynamic>{'type': 'platform'},
              },
            ])
              WalletHistoryItem(
                transaction: WalletTransactionModel.fromJson(json),
              ),
          ],
        ),
      ),
    );

    // The harness loads no translations, so a key renders as itself.
    expect(
      find.text('${LangKeys.walletOrderPaymentKey} · ORD-1'),
      findsOneWidget,
    );
    expect(find.text(LangKeys.walletOrderPaymentKey), findsOneWidget);
    expect(find.textContaining('GRP-1'), findsNothing);
    expect(find.textContaining('top-up ·'), findsNothing);
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

  testWidgets(
    'a multi-store payment lists its orders and opens the one picked',
    (tester) async {
      await pumpRow(tester, <String, dynamic>{
        'type': 'order_group',
        'uuid': 'group-uuid',
        'number': 'GRP-2026-00003',
        'orders': <Map<String, dynamic>>[
          <String, dynamic>{
            'uuid': 'a',
            'number': 'ORD-A',
            'store_name': 'Alfa',
          },
          <String, dynamic>{
            'uuid': 'b',
            'number': 'ORD-B',
            'store_name': 'Beta',
          },
        ],
      });

      expect(find.text('GRP-2026-00003'), findsNothing);
      expect(find.text('ORD-B'), findsNothing);

      await tester.tap(find.text('negm'));
      await tester.pumpAndSettle();

      expect(find.text('Alfa'), findsOneWidget);
      expect(find.text('ORD-A'), findsOneWidget);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(find.text('details b'), findsOneWidget);
    },
  );
}
