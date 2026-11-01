import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// The saved-card entry fields (cardholder name, number, expiry, CVV), shared by
/// every add-card surface.
///
/// Presentational: pass a [TextEditingController] per field to read what the
/// user typed and, under a [Form] ancestor, validate it — the add-card sheet and
/// screen do this. Callers that leave the controllers null get the same
/// typeable-but-unwired fields as before. The required validators are inert
/// until an enclosing [Form] calls `validate()`, so unwired callers are
/// unaffected.
class AddCardForm extends StatelessWidget {
  const AddCardForm({
    super.key,
    this.labelColor,
    this.hintColor,
    this.fieldColor,
    this.nameController,
    this.numberController,
    this.expiryController,
    this.cvvController,
    this.optionalSecrets = false,
  });
  final Color? labelColor;
  final Color? hintColor;
  final Color? fieldColor;
  final TextEditingController? nameController;
  final TextEditingController? numberController;
  final TextEditingController? expiryController;
  final TextEditingController? cvvController;

  /// When true (edit mode), the card number and CVC may be left blank to keep
  /// the existing values — a saved card never returns the full number or CVC to
  /// prefill, so requiring them would force re-typing the whole card just to
  /// change the name or expiry. A blank field skips validation; a filled one is
  /// still format-checked.
  final bool optionalSecrets;

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty)
          ? LangKeys.requiredFieldKey.tr()
          : null;

  static const int _minCardNumberLength = 12;
  static const int _maxCardNumberLength = 19;

  /// Card number: 12–19 digits (the backend's range) passing the Luhn checksum
  /// (catches typos), except UnionPay (`62…`), whose numbers need not pass it.
  /// In edit mode an empty value is allowed (keeps the stored number).
  String? _cardNumber(String? value) {
    final String digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return optionalSecrets ? null : LangKeys.requiredFieldKey.tr();
    }
    final bool validLength =
        digits.length >= _minCardNumberLength &&
        digits.length <= _maxCardNumberLength;
    final bool exemptFromLuhn = digits.startsWith('62');
    if (!validLength || (!exemptFromLuhn && !_passesLuhn(digits))) {
      return LangKeys.invalidCardNumberKey.tr();
    }
    return null;
  }

  /// No card is issued for longer than this, so a later expiry is a typo.
  static const int _maxYearsAhead = 30;

  /// Expiry: present, an MM/YY with a real month, not already past (a card
  /// is valid through the last day of its expiry month) and at most
  /// [_maxYearsAhead] years away.
  String? _expiry(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return LangKeys.requiredFieldKey.tr();

    final RegExpMatch? match =
        RegExp(r'^(\d{2})/?(\d{2})$').firstMatch(text);
    if (match == null) return LangKeys.invalidExpiryDateKey.tr();

    final int month = int.parse(match.group(1)!);
    final int year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return LangKeys.invalidExpiryDateKey.tr();

    final DateTime now = DateTime.now();
    if (year > now.year + _maxYearsAhead) {
      return LangKeys.invalidExpiryDateKey.tr();
    }
    // Day 0 of the next month is the last day of the expiry month.
    final DateTime endOfExpiryMonth = DateTime(year, month + 1, 0);
    if (endOfExpiryMonth.isBefore(DateTime(now.year, now.month, now.day))) {
      return LangKeys.cardExpiredKey.tr();
    }
    return null;
  }

  /// CVV: 3–4 digits (4 for Amex, 3 otherwise). In edit mode an empty value is
  /// allowed (keeps the stored CVC).
  String? _cvv(String? value) {
    final String digits = (value ?? '').trim();
    if (digits.isEmpty) {
      return optionalSecrets ? null : LangKeys.requiredFieldKey.tr();
    }
    if (digits.length < 3 || digits.length > 4) {
      return LangKeys.invalidCvvKey.tr();
    }
    return null;
  }

  /// Standard Luhn (mod-10) checksum used by every major card network.
  static bool _passesLuhn(String digits) {
    int sum = 0;
    bool doubleNext = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = digits.codeUnitAt(i) - 0x30; // '0'
      if (doubleNext) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleNext = !doubleNext;
    }
    return sum % 10 == 0;
  }

  /// Whether the controllers' text passes every validator, without showing any
  /// error — the add-card sheet keeps its submit button disabled until it does.
  bool get isComplete =>
      _required(nameController?.text) == null &&
      _cardNumber(numberController?.text) == null &&
      _expiry(expiryController?.text) == null &&
      _cvv(cvvController?.text) == null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(LangKeys.cardholderNameKey.tr(), color: labelColor),
          const SizedBox(height: 10),
          _CardInputField(
            controller: nameController,
            validator: _required,
            hintText: LangKeys.nameHintKey.tr(),
            hintColor: hintColor,
            fieldColor: fieldColor,
            keyboardType: TextInputType.name,
            // The name as printed on the card: English letters and spaces.
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
            ],
          ),

          const SizedBox(height: 18),

          _FieldLabel(LangKeys.cardNumberKey.tr(), color: labelColor),
          const SizedBox(height: 10),
          _CardInputField(
            controller: numberController,
            validator: _cardNumber,
            hintText: '0000 0000 0000 0000',
            hintColor: hintColor,
            fieldColor: fieldColor,
            keyboardType: TextInputType.number,
            isLtr: true,
            inputFormatters: <TextInputFormatter>[
              CardNumberInputFormatter(),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _CardFieldColumn(
                  controller: expiryController,
                  validator: _expiry,
                  hintColor: hintColor,
                  fieldColor: fieldColor,
                  labelColor: labelColor,
                  label: LangKeys.expirationDateKey.tr(),
                  hint: LangKeys.expiryDateHintKey.tr(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    _ExpiryDateInputFormatter(),
                  ],
                ),
              ),

              Expanded(
                child: _CardFieldColumn(
                  controller: cvvController,
                  validator: _cvv,
                  labelColor: labelColor,
                  hintColor: hintColor,
                  fieldColor: fieldColor,
                  label: LangKeys.cvvKey.tr(),
                  hint: '000',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardFieldColumn extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final Color? hintColor;
  final Color? fieldColor;
  final String hint;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _CardFieldColumn({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.labelColor,
    this.fieldColor,
    this.hintColor,
    this.controller,
    this.validator,
    this.inputFormatters,
  }) : textAlign = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label, color: labelColor),
        const SizedBox(height: 10),
        _CardInputField(
          hintText: hint,
          keyboardType: keyboardType,
          textAlign: textAlign,
          fieldColor: fieldColor,
          hintColor: hintColor,
          controller: controller,
          validator: validator,
          inputFormatters: inputFormatters,
          // Expiry and CVV are digits: keep them left-to-right in Arabic too.
          isLtr: true,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const _FieldLabel(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Text(
      text,
      style: AppTextStyles.style14Medium.copyWith(
        color: color ?? colors.black,
      ),
    );
  }
}

class _CardInputField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final Color? hintColor;
  final Color? fieldColor;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  /// Digits (number, expiry, CVV) read left-to-right even in Arabic, or the
  /// groups of a card number come out reversed.
  final bool isLtr;

  const _CardInputField({
    required this.hintText,
    this.keyboardType,
    this.textAlign,
    this.hintColor,
    this.fieldColor,
    this.controller,
    this.validator,
    this.inputFormatters,
    this.isLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // The field is a borderless filled pill — validation only shows the message
    // below, never a red outline. Focus adds the primary ring (RoundedField's
    // style), with or without an error.
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
    final OutlineInputBorder focused = border.copyWith(
      borderSide: BorderSide(color: colors.primary500Main, width: 1.5),
    );
    final TextDirection? direction = isLtr ? TextDirection.ltr : null;
    return InputDirectionBuilder(
      controller: controller,
      builder: (BuildContext context, TextDirection? typedDirection) =>
          TextFormField(
            contextMenuBuilder: appContextMenuBuilder,
            controller: controller,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            textDirection: direction ?? typedDirection,
            // Left-to-right digits still sit on the locale's start edge, as in
            // the phone field: right in Arabic.
            textAlign:
                textAlign ??
                (isLtr && Directionality.of(context) == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.start),
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              counterText: '',
              hintText: hintText,
              hintTextDirection: direction,
              hintStyle: TextStyle(
                color: hintColor ?? colors.neutral500,
                fontSize: 15,
              ),
              filled: true,
              fillColor: fieldColor ?? colors.neutral200.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              enabledBorder: border,
              focusedBorder: focused,
              errorBorder: border,
              focusedErrorBorder: focused,
            ),
          ),
    );
  }
}

/// Keeps the expiry field in `MM/YY` shape as the user types: it strips
/// non-digits, caps at four digits, and inserts the slash after the month.
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    final String formatted = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)}/${digits.substring(2)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Groups the card number in fours as the user types (`4111 1111 1111 1111`):
/// strips non-digits, caps at 19 digits and keeps the caret after the same
/// digit. The spaces are display-only; the view model strips them.
class CardNumberInputFormatter extends TextInputFormatter {
  static final RegExp _nonDigit = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(_nonDigit, '');
    final int caret = newValue.selection.baseOffset.clamp(
      0,
      newValue.text.length,
    );
    int before = newValue.text
        .substring(0, caret)
        .replaceAll(_nonDigit, '')
        .length;

    // Backspace on a group space removes no digit; drop the one before it,
    // or the caret would be stuck behind the re-inserted space.
    final bool deletedOnlySpace =
        newValue.text.length < oldValue.text.length &&
        digits == oldValue.text.replaceAll(_nonDigit, '');
    if (deletedOnlySpace && before > 0) {
      digits = digits.substring(0, before - 1) + digits.substring(before);
      before--;
    }

    if (digits.length > AddCardForm._maxCardNumberLength) {
      digits = digits.substring(0, AddCardForm._maxCardNumberLength);
    }
    if (before > digits.length) before = digits.length;

    final String formatted = digits.replaceAllMapped(
      RegExp(r'.{4}(?!$)'),
      (Match m) => '${m[0]} ',
    );
    // Each full group of four before the caret adds one space.
    final int offset = before == 0 ? 0 : before + (before - 1) ~/ 4;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
