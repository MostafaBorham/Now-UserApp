import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_card_widget.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_transactions_vm.dart';

import '../../helpers/categories_test_harness.dart';

class _FakeWalletInfoViewModel extends GetWalletInfoViewModel {
  _FakeWalletInfoViewModel() {
    state = const AsyncValue<WalletModel>.data(WalletModel(balance: 120));
  }

  int fetchCount = 0;

  @override
  Future<void> getWalletInfo() async => fetchCount++;
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

  int firstPageCount = 0;

  @override
  Future<void> loadFirstPage() async => firstPageCount++;
}

/// Pulling down anywhere on the wallet screen — the card as well as the
/// history — reloads both the balance and the history.
void main() {
  setUpAll(initCategoriesTestLocalization);

  late _FakeWalletInfoViewModel infoVm;
  late _FakeWalletTransactionsViewModel transactionsVm;

  Future<void> pumpScreen(WidgetTester tester) async {
    infoVm = _FakeWalletInfoViewModel();
    transactionsVm = _FakeWalletTransactionsViewModel();
    await pumpCategoriesScreen(
      tester,
      const WalletScreen(),
      overrides: <Override>[
        getWalletInfoProvider.overrideWith((Ref ref) => infoVm),
        getWalletTransactionsProvider.overrideWith((Ref ref) => transactionsVm),
      ],
    );
    await tester.pump();
  }

  Future<void> pullDownFrom(WidgetTester tester, Finder finder) async {
    await tester.fling(finder, const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('pulling on the wallet card reloads the info and the history', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);
    final int infoFetchesOnOpen = infoVm.fetchCount;

    await pullDownFrom(tester, find.byType(WalletCardWidget));

    expect(infoVm.fetchCount, infoFetchesOnOpen + 1);
    expect(transactionsVm.firstPageCount, 1);
  });

  testWidgets('pulling on the history reloads the info and the history', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);
    final int infoFetchesOnOpen = infoVm.fetchCount;

    await pullDownFrom(tester, find.byType(NoResultsWidget));

    expect(infoVm.fetchCount, infoFetchesOnOpen + 1);
    expect(transactionsVm.firstPageCount, 1);
  });
}
