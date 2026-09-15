import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';






class OrderCanceledView extends StatelessWidget {
  const OrderCanceledView({
    super.key,
    required this.onContinueShopping,
    required this.onViewOrders,
  });


  final VoidCallback onContinueShopping;


  final VoidCallback onViewOrders;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
