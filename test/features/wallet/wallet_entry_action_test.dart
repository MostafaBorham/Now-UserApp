import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_balance_view.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_transactions_vm.dart';

import '../../helpers/categories_test_harness.dart';

class _FakeWalletInfoViewModel extends GetWalletInfoViewModel {
  _FakeWalletInfoViewModel() {
    state = const AsyncValue<WalletModel>.data(WalletModel(balance: 20));
  }

  @override
  Future<void> getWalletInfo() async {}
}

class _FakeWalletTransactionsViewModel extends GetWalletTransactionsViewModel {
  _FakeWalletTransactionsViewModel() {
    state = const AsyncValue<PaginationModel<WalletTransactionModel>>.data(
      PaginationModel<WalletTransactionModel>(
        currentPage: 1,
        lastPage: 1,
        perPage: 10,
        total: 0,
        hasMore: false,
        data: <WalletTransactionModel>[],
      ),
    );
  }

  @override
  Future<void> loadFirstPage() async {}
}

class _FakeCardsViewModel extends GetMyCardsViewModel {
  _FakeCardsViewModel() {
    state = const AsyncValue<List<CardPaymentModel>>.data(
      <CardPaymentModel>[],
    );
  }

  @override
  Future<void> getMyCards() async {}
}

/// Checkout's "top up" link opens the wallet straight on its add-balance
/// sheet; opened any other way, the wallet shows its overview.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<void> pumpWallet(
    WidgetTester tester, {
    WalletEntryAction? entryAction,
  }) async {
    await pumpCategoriesScreen(
      tester,
      WalletScreen(entryAction: entryAction),
      overrides: <Override>[
        getWalletInfoProvider.overrideWith(
          (Ref ref) => _FakeWalletInfoViewModel(),
        ),
        getWalletTransactionsProvider.overrideWith(
          (Ref ref) => _FakeWalletTransactionsViewModel(),
        ),
        getMyCardsProvider.overrideWith((Ref ref) => _FakeCardsViewModel()),
      ],
    );
    await tester.pump();
    // The sheet's entrance animation.
    await tester.pump(const Duration(milliseconds: 500));
    for (
      Object? ex = tester.takeException();
      ex != null;
      ex = tester.takeException()
    ) {
      expect(ex.toString(), contains('overflow'));
    }
  }

  testWidgets('the add-balance entry opens the top-up sheet', (
    WidgetTester tester,
  ) async {
    await pumpWallet(tester, entryAction: WalletEntryAction.addBalance);

    expect(find.byType(AddBalanceView), findsOneWidget);
  });

  testWidgets('a plain open shows the wallet without a sheet', (
    WidgetTester tester,
  ) async {
    await pumpWallet(tester);

    expect(find.byType(AddBalanceView), findsNothing);
  });
}
