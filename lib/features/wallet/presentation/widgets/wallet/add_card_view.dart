import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_form.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/set_as_default_checkbox.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/add_payment_card_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

/// The add-or-edit card bottom sheet. Passing [card] puts it in edit mode:
/// the cardholder name, expiry and default flag are prefilled, the number and
/// CVC start blank (a saved card never returns them), and submitting updates the
/// card instead of creating one.
class AddCardView extends ConsumerStatefulWidget {
  const AddCardView({super.key, this.card});

  /// The card to edit, or `null` to add a new one.
  final CardPaymentModel? card;

  /// Presents the sheet as a scroll-controlled modal, matching the add-card
  /// sheet's presentation. Pass [card] to open it in edit mode.
  static Future<void> show(BuildContext context, {CardPaymentModel? card}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.white,
      builder: (BuildContext sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
        ),
        child: AddCardView(card: card),
      ),
    );
  }

  @override
  ConsumerState<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends ConsumerState<AddCardView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _setAsDefault = false;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    final CardPaymentModel? card = widget.card;
    if (card != null) {
      // Prefill what a saved card exposes; the full number and CVC are never
      // returned, so those fields stay blank (optional in edit mode).
      _nameController.text = card.cardholderName ?? '';
      _expiryController.text = _formatExpiry(card);
      _setAsDefault = card.isDefault ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  static String _formatExpiry(CardPaymentModel card) {
    final String? expiry = card.expiry;
    if (expiry != null && expiry.isNotEmpty) return expiry;
    final int? month = card.expiryMonth;
    final int? year = card.expiryYear;
    if (month == null || year == null) return '';
    return '${month.toString().padLeft(2, '0')}/'
        '${(year % 100).toString().padLeft(2, '0')}';
  }

  String? get _numberHint {
    final CardPaymentModel? card = widget.card;
    if (card == null) return null;
    if (card.maskedNumber != null) return card.maskedNumber;
    if (card.lastFour != null) return '•••• ${card.lastFour}';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AddPaymentCardViewModel notifier =
        ref.read(addPaymentCardProvider.notifier);

    final String? error = _isEditing
        ? await notifier.updatePaymentCard(
            cardId: widget.card!.id!,
            cardholderName: _nameController.text.trim(),
            expiry: _expiryController.text,
            cardNumber: _numberController.text,
            cvc: _cvvController.text,
            setAsDefault: _setAsDefault,
          )
        : await notifier.addPaymentCard(
            cardholderName: _nameController.text.trim(),
            cardNumber: _numberController.text,
            expiry: _expiryController.text,
            cvc: _cvvController.text,
            setAsDefault: _setAsDefault,
          );

    if (!mounted) return;
    if (error != null) {
      // Surface the error and keep the sheet open so the customer can retry; the
      // toast floats on the root overlay, above the sheet.
      AppToast.showError(context, error);
      return;
    }
    AppToast.showSuccess(
      context,
      _isEditing
          ? LangKeys.cardUpdatedSuccessfullyKey
          : LangKeys.cardAddedSuccessfullyKey,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isSubmitting = ref.watch(addPaymentCardProvider).isLoading;

    // Block dismissal while the save is in flight, so the sheet can't be closed
    // out from under a request that is about to refetch the cards list.
    return PopScope(
      canPop: !isSubmitting,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    AutoSizeText(
                      (_isEditing
                              ? LangKeys.editCardKey
                              : LangKeys.addCardKey)
                          .tr(),
                      style: AppTextStyles.style18Medium.copyWith(
                        color: colors.black,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsetsGeometry.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: isSubmitting ? null : () => context.pop(),
                      icon: Icon(Icons.clear, size: 20, color: colors.black),
                    ),
                  ],
                ),
                AddCardForm(
                  nameController: _nameController,
                  numberController: _numberController,
                  expiryController: _expiryController,
                  cvvController: _cvvController,
                  optionalSecrets: _isEditing,
                  numberHint: _numberHint,
                ),
                SetAsDefaultCheckbox(
                  value: _setAsDefault,
                  onChanged: isSubmitting
                      ? null
                      : (bool v) => setState(() => _setAsDefault = v),
                ),
                2.hSpace,
                PrimaryAppButton(
                  title: (_isEditing ? LangKeys.saveKey : LangKeys.addNewCardKey)
                      .tr(),
                  isLoading: isSubmitting,
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
