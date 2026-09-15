import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/payment_methods/presentation/components/payment_option.dart';
import 'package:nowdelivery_user_app/features/payment_methods/presentation/components/payment_option_tile.dart';





class RetryPaymentMethodsSection extends StatefulWidget {
  const RetryPaymentMethodsSection({super.key, this.initial});

  final PaymentOption? initial;

  @override
  State<RetryPaymentMethodsSection> createState() =>
      _RetryPaymentMethodsSectionState();
}

class _RetryPaymentMethodsSectionState
    extends State<RetryPaymentMethodsSection> {
  late PaymentOption _selected = widget.initial ?? PaymentOption.masterCard;

  void _select(PaymentOption option) => setState(() => _selected = option);

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LangKeys.tryAnotherPaymentMethodKey.tr(),
          style: AppTextStyles.style16SemiBold.copyWith(
            color: colors.black,
          ),
        ),
        14.hSpace,
        PaymentOptionTile(
          leading: Assets.media.images.svg.masterCardCircle.svg(),
          title: LangKeys.paymentCardKey.tr(),
          subtitle: '•••• 4827',
          isSelected: _selected == PaymentOption.masterCard,
          onTap: () => _select(PaymentOption.masterCard),
        ),
        12.hSpace,
        PaymentOptionTile(
          leading: Assets.media.images.svg.applePay.svg(),
          title: LangKeys.applePayKey.tr(),
          isSelected: _selected == PaymentOption.applePay,
          onTap: () => _select(PaymentOption.applePay),
        ),
        12.hSpace,
        PaymentOptionTile(
          leading: Assets.media.images.svg.stc.svg(),
          title: LangKeys.stcPayKey.tr(),
          isSelected: _selected == PaymentOption.stcPay,
          onTap: () => _select(PaymentOption.stcPay),
        ),
      ],
    );
  }
}
