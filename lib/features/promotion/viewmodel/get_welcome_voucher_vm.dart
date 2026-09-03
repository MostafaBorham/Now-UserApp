import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/promotion/data/repo/promotion_repo.dart';

/// The fixed code of the first-order welcome voucher. The banner fetches this
/// coupon from `GET /api/v1/coupons/WELCOME10` and shows whatever `code` the
/// server returns. If the coupon is disabled/deleted the endpoint 404s and the
/// banner simply doesn't render.
const String welcomeVoucherCode = 'WELCOME10';

/// One-shot fetch of the welcome voucher. Returns `null` on any failure
/// (offline, 404, inactive) so the caller can just hide the banner.
///
/// `autoDispose` and lazily fired on first `watch`: because the banner only
/// watches this *after* confirming the user is eligible (empty cart + no
/// previous orders), the request never fires for users who wouldn't see it.
final welcomeVoucherProvider = FutureProvider.autoDispose<CouponModel?>((
  Ref ref,
) async {
  final result = await PromotionRepo().getCoupon(welcomeVoucherCode);
  return result.fold((_) => null, (CouponModel coupon) => coupon);
});
