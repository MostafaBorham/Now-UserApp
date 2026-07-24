import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg_provider;
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_form.dart';

class AddPaymentCardScreen extends StatelessWidget {
  const AddPaymentCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedView(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                "Add New Card",
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(25),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: svg_provider.Svg(Assets.media.images.svg.card.path),
                  ),
                ),
                child: AddCardForm(
                  lableColor: colors.onPrimary,
                  hintColor: Colors.white,
                ),
              ),
              Text(
                "Another payment method",
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              MultiRadioTile(
                colors: colors,
                items: [
                  PaymentMethodItem(
                    title: "Apple Pay",
                    icon: Assets.media.images.svg.applePay.svg(),
                    value: "apple_pay",
                  ),
                  PaymentMethodItem(
                    title: "STC pay",
                    icon: Assets.media.images.svg.stc.svg(),
                    value: "stc_pay",
                  ),
                ],
                onSelected: (value) {},
              ),
              PrimaryAppPrefixIconButton(
                title: "Add",
                prefixIcon: Assets.media.images.svg.addCircle.svg(),
                onTap: () => context.pushNamed(AppRoutes.paymentMethodsScreen),
              ),
              10.hSpace,
            ],
          ),
        ),
        appBarTitle: context.tr(LangKeys.addCardKey),
      ),
    );
  }
}

class PaymentMethodItem<T> {
  final String title;
  final Widget icon;
  final T value;

  PaymentMethodItem({
    required this.title,
    required this.icon,
    required this.value,
  });
}

class MultiRadioTile<T> extends StatelessWidget {
  const MultiRadioTile({
    super.key,
    required this.colors,
    required this.onSelected,
    required this.items,
    this.groupValue,
  });

  final ColorScheme colors;
  final ValueChanged<T?> onSelected;
  final List<PaymentMethodItem<T>> items;
  final T? groupValue;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      child: RadioGroup<T>(
        groupValue: groupValue, // ربط القيمة المختارة بالـ RadioGroup
        onChanged: onSelected,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: items.map((item) {
            return ListTile(
              leading: item.icon,
              title: Text(
                item.title,
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              trailing: Radio<T>.adaptive(value: item.value),

              onTap: () => onSelected(item.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
