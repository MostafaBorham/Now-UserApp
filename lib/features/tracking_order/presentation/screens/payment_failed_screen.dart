import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';

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
    final AppColorScheme colors = context.colors;
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
              PrimaryAppButton(
                titleStyle: AppTextStyles.style14Medium,
                title: LangKeys.retryKey.tr(),
                buttonPadding: 16,
                prefixIcon: Assets.media.images.svg.retryIcon.svg(
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () {},
              ),
              12.hSpace,
              UnPrimaryAppButton(
                title: LangKeys.backToOrderKey.tr(),
                buttonPadding: 16,
                side: BorderSide(
                  color: colors.neutral400.withValues(alpha: 0.5),
                ),
                titleColor: colors.black,
                onTap: () => context.pop(),
              ),
              12.hSpace,
            ],
          ),
        ),
      ),
    );
  }
}
