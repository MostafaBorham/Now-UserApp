import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// Single task: expose the customer's saved payment cards.
///
/// `autoDispose`: torn down when its consumer leaves. The list starts as soon
/// as the provider is first read/watched; `loadFirstPage()` (refresh / retry)
/// comes from [PaginatedViewModel]. The endpoint returns every card in one shot
/// with no `meta`, so the repo wraps it in a single-page [PaginationModel] and
/// [fetchPage] ignores the requested [page].
final getMyCardsProvider = StateNotifierProvider.autoDispose<
    GetMyCardsViewModel,
    AsyncValue<PaginationModel<CardPaymentModel>>>(
  (Ref ref) => GetMyCardsViewModel()..loadFirstPage(),
);

class GetMyCardsViewModel extends PaginatedViewModel<CardPaymentModel> {
  final WalletRepo _repo = WalletRepo();

  @override
  Future<Either<Failure, PaginationModel<CardPaymentModel>>> fetchPage(
    int page,
  ) {
    return _repo.getMyCards();
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
