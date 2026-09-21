import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg_provider;
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_form.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/set_as_default_checkbox.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/add_payment_card_vm.dart';

class AddPaymentCardScreen extends ConsumerStatefulWidget {
  const AddPaymentCardScreen({super.key});

  @override
  ConsumerState<AddPaymentCardScreen> createState() =>
      _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends ConsumerState<AddPaymentCardScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _setAsDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String? error = await ref
        .read(addPaymentCardProvider.notifier)
        .addPaymentCard(
          cardholderName: _nameController.text.trim(),
          cardNumber: _numberController.text,
          expiry: _expiryController.text,
          cvc: _cvvController.text,
          setAsDefault: _setAsDefault,
        );

    if (!mounted) return;
    if (error != null) {
      AppToast.showError(context, error);
      return;
    }
    AppToast.showSuccess(context, LangKeys.cardAddedSuccessfullyKey);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isSubmitting = ref.watch(addPaymentCardProvider).isLoading;
    return Scaffold(
      body: AppWavedView(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  LangKeys.addNewCardKey.tr(),
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
                    labelColor: colors.white,
                    hintColor: Colors.white,
                    nameController: _nameController,
                    numberController: _numberController,
                    expiryController: _expiryController,
                    cvvController: _cvvController,
                  ),
                ),
                SetAsDefaultCheckbox(
                  value: _setAsDefault,
                  labelColor: colors.tertiaryContainer,
                  onChanged: isSubmitting
                      ? null
                      : (bool v) => setState(() => _setAsDefault = v),
                ),
                Text(
                  LangKeys.anotherPaymentMethodKey.tr(),
                  style: AppTextStyles.style16Medium.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                MultiRadioTile(
                  colors: colors,
                  items: [
                    PaymentMethodItem(
                      title: LangKeys.applePayKey.tr(),
                      icon: Assets.media.images.svg.applePay.svg(),
                      value: "apple_pay",
                    ),
                    PaymentMethodItem(
                      title: LangKeys.stcPayKey.tr(),
                      icon: Assets.media.images.svg.stc.svg(),
                      value: "stc_pay",
                    ),
                  ],
                  onSelected: (value) {},
                ),
                PrimaryAppPrefixIconButton(
                  title: LangKeys.addKey.tr(),
                  prefixIcon: Assets.media.images.svg.addCircle.svg(),
                  isLoading: isSubmitting,
                  onTap: _submit,
                ),
                10.hSpace,
              ],
            ),
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

  final AppColorScheme colors;
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
        groupValue: groupValue,
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
