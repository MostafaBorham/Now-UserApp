import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

import 'add_payment_card_screen.dart';
import 'components/add_new_card_bottom_sheet.dart';
import 'components/add_new_card_button.dart';
import 'components/add_new_card_section.dart';
import 'components/payment_option.dart';
import 'components/section_title.dart';

/// Payment Methods screen: pick a saved card or another payment method,
/// or fill in a new card, then continue.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  PaymentOption _selected = PaymentOption.visa;

  void _select(PaymentOption option) => setState(() => _selected = option);

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.paymentMethodsKey.tr(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(LangKeys.savedCardsKey.tr()),
                    MultiRadioTile<PaymentOption>(
                      colors: colors,
                      onSelected: (value) => _select(value!),
                      groupValue: _selected,
                      items: [
                        PaymentMethodItem(
                          icon: Assets.media.images.svg.blueCircle.svg(),
                          title: 'Visa ****4587',
                          value: PaymentOption.visa,
                        ),
                        PaymentMethodItem(
                          icon: Assets.media.images.svg.masterCardCircle.svg(),
                          title: 'Master Card ****4874',
                          value: PaymentOption.masterCard,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    SectionTitle(LangKeys.anotherPaymentMethodKey.tr()),

                    MultiRadioTile<PaymentOption>(
                      colors: colors,
                      onSelected: (value) => _select(value!),
                      groupValue: _selected,
                      items: [
                        PaymentMethodItem(
                          icon: Assets.media.images.svg.applePay.svg(),
                          title: LangKeys.applePayKey.tr(),
                          value: PaymentOption.applePay,
                        ),
                        PaymentMethodItem(
                          icon: Assets.media.images.svg.stc.svg(),
                          title: LangKeys.stcPayKey.tr(),
                          value: PaymentOption.stcPay,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const AddNewCardSection(),
                  ],
                ),
              ),
            ),
            const _BottomActions(),
          ],
        ),
      ),
    );
  }
}

/// Docked actions below the scrolling content: the outlined "Add New Card"
/// button and the primary "Continue" button, framed by hairlines.
class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: context.colors.neutral200),
        const SizedBox(height: 14),
        AddNewCardButton(onTap: () => AddNewCardBottomSheet.show(context)),
        const SizedBox(height: 14),
        Divider(height: 1, thickness: 1, color: context.colors.neutral200),
        const SizedBox(height: 14),
        PrimaryAppButton(
          title: LangKeys.continueKey.tr(),
          onTap: () => context.pushNamed(AppRoutes.phoneVerificationScreen),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
