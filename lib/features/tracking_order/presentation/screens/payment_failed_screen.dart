import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';

import '../components/order_amount_card.dart';
import '../components/payment_error_banner.dart';
import '../components/payment_failed_header.dart';
import '../components/retry_payment_methods_section.dart';

/// Payment Failed screen: explains the failed charge, shows the amount due,
/// lets the user pick another method and retry — or go back to the order.
class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: AlignmentGeometry.topCenter,
            radius: 0.9,
            colors: [Color(0xffFEE2E2), Color(0xffFFF5F5), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PaymentFailedHeader(),
                      24.hSpace,
                      const PaymentErrorBanner(),
                      16.hSpace,
                      const OrderAmountCard(),
                      20.hSpace,
                      const RetryPaymentMethodsSection(),
                      16.hSpace,
                    ],
                  ),
                ),
              ),
              12.hSpace,
              PrimaryAppPrefixIconButton(
                title: LangKeys.retryKey.tr(),
                buttonPadding: 16,
                prefixIcon: Assets.media.images.svg.retryIcon.svg(
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    colors.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () {},
              ),
              12.hSpace,
              UnPrimaryButton(
                title: LangKeys.backToOrderKey.tr(),
                buttonPadding: 16,
                onTap: () => Navigator.maybePop(context),
              ),
              12.hSpace,
            ],
          ),
        ),
      ),
    );
  }
}
