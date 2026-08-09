import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';

/// Single task: fetch the available coupons, one page at a time.
///
/// The first page is fetched as soon as the provider is first watched, so
/// screens only need to `ref.watch(getCouponsProvider)` and render the
/// [AsyncValue]. Later pages are pulled in with [loadMore], whose progress is
/// exposed separately through [GetCouponsViewModel.loadMoreState] so the
/// already-visible list is never replaced by a full-screen loading/error state.
final getCouponsProvider =
    StateNotifierProvider<
      GetCouponsViewModel,
      AsyncValue<PaginationModel<CouponModel>>
    >((Ref ref) => GetCouponsViewModel(const AsyncValue.loading())..getCoupons());

class GetCouponsViewModel
    extends StateNotifier<AsyncValue<PaginationModel<CouponModel>>> {
  GetCouponsViewModel(super.initialState);

  final PromotionRepo _repo = PromotionRepo();

  final ValueNotifier<AsyncValue<bool>> loadMoreState =
      ValueNotifier<AsyncValue<bool>>(const AsyncValue<bool>.data(true));

  @override
  void dispose() {
    _repo.cancelRequests();
    loadMoreState.dispose();
    super.dispose();
  }

  Future<void> getCoupons() async {
    state = const AsyncValue<PaginationModel<CouponModel>>.loading();

    final Either<Failure, PaginationModel<CouponModel>> result =
        await _fetchPage(1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        state = AsyncValue<PaginationModel<CouponModel>>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<CouponModel> firstPage) {
        state = AsyncValue<PaginationModel<CouponModel>>.data(firstPage);
        loadMoreState.value = AsyncValue<bool>.data(firstPage.hasMore);
      },
    );
  }

  Future<void> loadMore() async {
    final PaginationModel<CouponModel>? currentPage = state.valueOrNull;

    if (currentPage == null ||
        !currentPage.hasMore ||
        loadMoreState.value.isLoading) {
      return;
    }

    loadMoreState.value = const AsyncValue<bool>.loading();

    final Either<Failure, PaginationModel<CouponModel>> result =
        await _fetchPage(currentPage.currentPage + 1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        loadMoreState.value = AsyncValue<bool>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<CouponModel> newPage) {
        // Append the freshly fetched page to the visible list.
        state = AsyncValue<PaginationModel<CouponModel>>.data(
          currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }

  Future<Either<Failure, PaginationModel<CouponModel>>> _fetchPage(int page) {
    return _repo.getCoupons(page: page);
  }
}
