import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';

import 'cancel_sheet_scaffold.dart';

/// The [MainScreen] bottom-nav index of the My Orders tab (Home, Favourites,
/// Cart, **My Orders**, Settings).
const int _myOrdersTabIndex = 3;

/// Success bottom sheet shown after an order is canceled: confirms the refund
/// and offers to keep shopping or review orders.
class OrderCanceledBottomSheet extends ConsumerWidget {
  const OrderCanceledBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const OrderCanceledBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // Just dismisses the sheet, returning to the (now cancelled) order.
    void onContinueShopping() => context.pop();
    // Resets the whole navigation stack to the Main screen and selects the My
    // Orders tab, so nothing from the cancel flow is left behind.
    void onViewOrders() {
      ref.read(mainTabIndexProvider.notifier).state = _myOrdersTabIndex;
      context.goNamed(AppRoutes.mainScreen);
    }

    return CancelSheetScaffold(
      children: [
        const SizedBox(height: 8),
        Center(child: Assets.media.images.svg.orderDone.svg()),
        const SizedBox(height: 24),
        Text(
          LangKeys.orderCanceledTitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style20Bold.copyWith(
            color: colors.black,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          LangKeys.orderCanceledSubtitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style14Regular.copyWith(
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 32),
        PrimaryAppButton(
          title: LangKeys.continueShoppingKey.tr(),
          buttonPadding: 16,
          onTap: onContinueShopping,
        ),
        const SizedBox(height: 12),
        UnPrimaryButton(
          title: LangKeys.viewOrdersKey.tr(),
          buttonPadding: 16,
          borderColor: colors.neutral200,
          onTap: onViewOrders,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
