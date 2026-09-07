import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';

/// The fixed code of the first-order welcome voucher, looked up from
/// `GET /api/v1/coupons/WELCOME10`.
const String welcomeVoucherCode = 'WELCOME10';

/// The welcome voucher, fetched server-first with an offline cache fallback
/// (see [PromotionRepo.getWelcomeVoucher]).
///
/// Kept alive (not `autoDispose`) so it is preloaded once on the splash — with
/// the other app dependencies — and reused by the empty-cart banner and the
/// guest settings without refetching. The fetch fires as soon as the view model
/// is constructed (first read/watch); consumers only `ref.watch` and read
/// `valueOrNull?.code`. Retry with
/// `ref.read(welcomeVoucherProvider.notifier).getWelcomeVoucher()`.
final welcomeVoucherProvider =
    StateNotifierProvider<GetWelcomeVoucherViewModel, AsyncValue<CouponModel>>(
  (Ref ref) => GetWelcomeVoucherViewModel()..getWelcomeVoucher(),
);

class GetWelcomeVoucherViewModel extends StateNotifier<AsyncValue<CouponModel>> {
  GetWelcomeVoucherViewModel() : super(const AsyncValue.loading());

  final PromotionRepo _repo = PromotionRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getWelcomeVoucher() async {
    state = const AsyncValue.loading();

    final result = await _repo.getWelcomeVoucher(welcomeVoucherCode);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (CouponModel coupon) => AsyncValue.data(coupon),
    );
  }
}
