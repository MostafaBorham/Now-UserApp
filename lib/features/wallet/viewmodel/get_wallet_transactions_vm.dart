import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';








final getWalletTransactionsProvider = StateNotifierProvider.autoDispose<
    GetWalletTransactionsViewModel,
    AsyncValue<PaginationModel<WalletTransactionModel>>>(
  (Ref ref) => GetWalletTransactionsViewModel()..loadFirstPage(),
);

class GetWalletTransactionsViewModel
    extends PaginatedViewModel<WalletTransactionModel> {
  final WalletRepo _repo = WalletRepo();

  @override
  Future<Either<Failure, PaginationModel<WalletTransactionModel>>> fetchPage(
    int page,
  ) {
    return _repo.getWalletTransactions(page: page);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
