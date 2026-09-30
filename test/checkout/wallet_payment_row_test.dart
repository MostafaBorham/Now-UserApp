import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/wallet_payment_row.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

import '../helpers/categories_test_harness.dart';

/// Holds a given wallet state and counts refetches instead of calling the API.
class _FakeWalletInfoViewModel extends GetWalletInfoViewModel {
  _FakeWalletInfoViewModel(AsyncValue<WalletModel> initial) {
    state = initial;
  }

  int fetches = 0;

  @override
  Future<void> getWalletInfo() async => fetches++;
}

/// Guards the wallet toggle: ticked on arrival (so the wallet is the default
/// payment method), and the shortfall note only when the balance can't cover
/// the total — there is no split payment, so a short wallet is refused.
void main() {
  setUpAll(initCategoriesTestLocalization);

  // No translations are loaded in the harness, so `.tr()` yields the key.
  Finder note() => find.text(LangKeys.walletShortfallHintKey);

  List<Override> priced({required double total, required int balance}) =>
      <Override>[
        checkoutModelProvider.overrideWith(
          (Ref ref) => CheckoutModel(orderGroup: OrderGroupModel(total: total)),
        ),
        getWalletInfoProvider.overrideWith(
          (Ref ref) =>
              GetWalletInfoViewModel()
                ..setWallet(WalletModel(balanceHalalas: balance)),
        ),
      ];

  testWidgets('a short wallet says so while ticked', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const WalletPaymentRow(),
      overrides: priced(total: 50, balance: 1000),
    );

    expect(note(), findsOneWidget);

    await tester.tap(find.text(LangKeys.walletKey));
    await tester.pump();

    expect(note(), findsNothing);
  });

  testWidgets('a wallet that covers the total shows no note', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const WalletPaymentRow(),
      overrides: priced(total: 50, balance: 5000),
    );

    expect(note(), findsNothing);
  });

  testWidgets('the note is never truncated', (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      const WalletPaymentRow(),
      overrides: priced(total: 50, balance: 1000),
    );

    // Every `AppTextStyles` entry bakes in `TextOverflow.ellipsis`, and an
    // ellipsis with no `maxLines` collapses the paragraph to a single line —
    // so the note must opt back out or it loses everything past line one.
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      note(),
    );
    expect(paragraph.overflow, TextOverflow.visible);
  });

  group('while the balance is not current, the row stays payable', () {
    Finder stale() => find.text(LangKeys.walletBalanceNotUpdatedKey);
    Finder tick() => find.byIcon(Icons.check_rounded);

    Future<_FakeWalletInfoViewModel> pumpRow(
      WidgetTester tester,
      AsyncValue<WalletModel> state,
    ) async {
      final _FakeWalletInfoViewModel vm = _FakeWalletInfoViewModel(state);
      await pumpCategoriesWidget(
        tester,
        const WalletPaymentRow(),
        overrides: <Override>[
          checkoutModelProvider.overrideWith(
            (Ref ref) => CheckoutModel(orderGroup: OrderGroupModel(total: 50)),
          ),
          getWalletInfoProvider.overrideWith((Ref ref) => vm),
        ],
      );
      return vm;
    }

    // The wallet is ticked by default, so the tick must stay reachable in every
    // state or the customer could never switch to a card.
    Future<void> expectUntickable(WidgetTester tester) async {
      expect(tick(), findsOneWidget);
      await tester.tap(find.text(LangKeys.walletKey));
      await tester.pump();
      expect(tick(), findsNothing);
    }

    testWidgets('first load: the amount shimmers', (tester) async {
      await pumpRow(tester, const AsyncValue<WalletModel>.loading());

      expect(find.byType(AppShimmer), findsOneWidget);
      expect(stale(), findsNothing);
      await expectUntickable(tester);
    });

    testWidgets('a failure with no balance says so and retries', (
      tester,
    ) async {
      final _FakeWalletInfoViewModel vm = await pumpRow(
        tester,
        AsyncValue<WalletModel>.error('boom', StackTrace.empty),
      );

      expect(stale(), findsOneWidget);
      await tester.tap(find.byType(GestureDetector).last);
      expect(vm.fetches, 1);
      await expectUntickable(tester);
    });

    testWidgets('a cached balance shows with the stale line', (tester) async {
      await pumpRow(
        tester,
        AsyncValue<WalletModel>.error(
          LangKeys.walletBalanceNotUpdatedKey,
          StackTrace.empty,
        ).copyWithPrevious(
          const AsyncValue<WalletModel>.data(WalletModel(balance: 120)),
        ),
      );

      expect(find.textContaining('120'), findsOneWidget);
      expect(stale(), findsOneWidget);
      await expectUntickable(tester);
    });

    testWidgets('a current balance shows no stale line', (tester) async {
      await pumpRow(
        tester,
        const AsyncValue<WalletModel>.data(WalletModel(balance: 120)),
      );

      expect(stale(), findsNothing);
      expect(find.byType(AppShimmer), findsNothing);
    });
  });

  test('the shortfall is judged in exact halalas', () {
    expect(
      walletFallsShort(const WalletModel(balanceHalalas: 1049), 10.5),
      isTrue,
    );
    expect(
      walletFallsShort(const WalletModel(balanceHalalas: 1050), 10.5),
      isFalse,
    );
    expect(walletFallsShort(const WalletModel(balance: 10.49), 10.5), isTrue);
    // Unknown balance: the server decides.
    expect(walletFallsShort(null, 10.5), isFalse);
  });
}
