import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_history_item.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_history_item_shimmer.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_transactions_vm.dart';









class WalletTransactionsView extends ConsumerWidget {
  const WalletTransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GetWalletTransactionsViewModel viewModel = ref.read(
      getWalletTransactionsProvider.notifier,
    );

    return PaginatedView<WalletTransactionModel>(
      provider: getWalletTransactionsProvider,
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,


      isFirstPageErrorScrollable: false,
      layout: PaginatedListLayout(
        separatorBuilder: (BuildContext context, int index) => 12.hSpace,
      ),
      placeholderBuilder: (BuildContext context) =>
          const WalletHistoryItemShimmer(),
      itemBuilder:
          (
            BuildContext context,
            WalletTransactionModel transaction,
            int index,
          ) => WalletHistoryItem(transaction: transaction),
    );
  }
}
