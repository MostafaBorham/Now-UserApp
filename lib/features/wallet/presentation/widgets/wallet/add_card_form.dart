import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AddCardForm extends StatelessWidget {
  const AddCardForm({
    super.key,
    this.lableColor,
    this.hintColor,
    this.fieldColor,
  });
  final Color? lableColor;
  final Color? hintColor;
  final Color? fieldColor;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(LangKeys.cardholderNameKey.tr(), color: lableColor),
          const SizedBox(height: 10),
          _CardInputField(
            hintText: LangKeys.nameHintKey.tr(),
            hintColor: hintColor,
            fieldColor: fieldColor,
          ),

          const SizedBox(height: 18),

          _FieldLabel(LangKeys.cardNumberKey.tr(), color: lableColor),
          const SizedBox(height: 10),
          _CardInputField(
            hintText: '1111-1111-1111-1111',
            hintColor: hintColor,
            fieldColor: fieldColor,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 18),

          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _CardFieldColumn(
                  hintColor: hintColor,
                  fieldColor: fieldColor,
                  labelColor: lableColor,
                  label: LangKeys.expirationDateKey.tr(),
                  hint: LangKeys.expiryDateHintKey.tr(),
                  keyboardType: TextInputType.datetime,
                ),
              ),

              Expanded(
                child: _CardFieldColumn(
                  labelColor: lableColor,
                  hintColor: hintColor,
                  fieldColor: fieldColor,
                  label: 'CVV',
                  hint: '1**',
                  keyboardType: TextInputType.number,
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

  const _CardFieldColumn({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.labelColor,
    this.fieldColor,
    this.hintColor,
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppTextStyles.style14Medium.copyWith(
        color: color ?? colors.onSecondary,
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

  const _CardInputField({
    required this.hintText,
    this.keyboardType,
    this.textAlign,
    this.hintColor,
    this.fieldColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return TextFormField(
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor ?? colors.onSurface,
          fontSize: 15,
        ),
        filled: true,
        fillColor: fieldColor ?? colors.onPrimary.withValues(alpha: 0.33),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
