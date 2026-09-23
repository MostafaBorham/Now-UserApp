import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';

/// Single task: page through the available coupons.
///
/// `autoDispose` and self-fetching: the Discount Codes screen is the only
/// consumer, so every open starts from a fresh first page — a coupon that
/// expired since the last visit is gone rather than listed until relaunch.
/// `loadNextPage()` and `loadFirstPage()` (refresh / retry) come from
/// [PaginatedViewModel].
final getCouponsProvider =
    StateNotifierProvider.autoDispose<
      GetCouponsViewModel,
      AsyncValue<PaginationModel<CouponModel>>
    >((Ref ref) => GetCouponsViewModel()..loadFirstPage());

class GetCouponsViewModel extends PaginatedViewModel<CouponModel> {
  final PromotionRepo _repo = PromotionRepo();

  @override
  Future<Either<Failure, PaginationModel<CouponModel>>> fetchPage(int page) =>
      _repo.getCoupons(page: page);

  @override
  bool Function(CouponModel, CouponModel)? get isSameItem =>
      (CouponModel a, CouponModel b) => a.id != null && a.id == b.id;

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
