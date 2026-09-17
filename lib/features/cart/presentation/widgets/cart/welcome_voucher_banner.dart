import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/fonts.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/copy_to_clipboard.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_welcome_voucher_vm.dart';

/// First-order incentive shown on the empty cart: a lavender pill inviting the
/// user to use the welcome voucher, which copies the code to the clipboard on tap.
///
/// Renders `SizedBox.shrink()` (nothing) unless the user is eligible:
/// * a **guest** — guests can't have placed an order, so they always qualify; or
/// * a **registered** user whose order count is exactly zero
///   ([getMyOrdersProvider] `total == 0`).
///
/// and the welcome coupon actually loads. After the first order is placed the
/// orders list is refreshed (see checkout success handler), `total` becomes ≥1,
/// and this banner disappears on its own.
class WelcomeVoucherBanner extends ConsumerWidget {
  const WelcomeVoucherBanner({super.key});

  // Figma 9648-57591 tokens (not app-theme colors — this pill is intentionally
  // off-palette).
  static const Color _bg = Color(0xFFEEF2FF);
  static const Color _text = Color(0xFF615FFF);
  static const Color _discount = Color(0xFFE32B3D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isGuest =
        ref.watch(authSessionProvider).sessionType == SessionType.guest;

    final bool hasNoOrders;
    if (isGuest) {
      hasNoOrders = true;
    } else {
      // Pre-fetched at session resolve; treat unknown (null) as "not eligible"
      // so the pill never flashes for a user who may already have orders.
      final orders = ref.watch(getMyOrdersProvider).valueOrNull;
      hasNoOrders = orders != null && orders.total == 0;
    }
    if (!hasNoOrders) return const SizedBox.shrink();

    final CouponModel? coupon = ref.watch(welcomeVoucherProvider).valueOrNull;
    final String? code = coupon?.code;
    if (code == null || code.isEmpty) return const SizedBox.shrink();

    const TextStyle base = TextStyle(
      fontFamily: FontFamily.cairo,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: _text,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => CopyToClipboard.copy(context, code),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Assets.media.images.svg.welcomeVoucherTagIcon.svg(
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    style: base,
                    children: <InlineSpan>[
                      TextSpan(text: LangKeys.welcomeVoucherPrefixKey.tr()),
                      TextSpan(
                        text: code,
                        style: base.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: LangKeys.welcomeVoucherMiddleKey.tr()),
                      TextSpan(
                        text: LangKeys.welcomeVoucherDiscountKey.tr(),
                        style: base.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _discount,
                        ),
                      ),
                      TextSpan(text: LangKeys.welcomeVoucherSuffixKey.tr()),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
