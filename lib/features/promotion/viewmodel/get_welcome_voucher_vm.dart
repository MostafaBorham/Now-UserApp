import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';



const String welcomeVoucherCode = 'WELCOME10';










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
