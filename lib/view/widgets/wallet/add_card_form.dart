import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class AddCardForm extends StatelessWidget {
  const AddCardForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('Cardholder Name'),
            const SizedBox(height: 10),
            const _CardInputField(
              hintText: 'Name ...',
            ),
        
            const SizedBox(height: 18),
        
            const _FieldLabel('Card Number'),
            const SizedBox(height: 10),
            const _CardInputField(
              hintText: '1111-1111-1111-1111',
              keyboardType: TextInputType.number,
            ),
        
            const SizedBox(height: 18),
        
            Row(
              spacing: 12,
              children: const [ Expanded(
                child: _CardFieldColumn(
                  label: 'Expiration Date',
                  hint: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                ),
              ),
        
                Expanded(
                  child: _CardFieldColumn(
                    label: 'CVV',
                    hint: '1**',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFieldColumn extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;

  const _CardFieldColumn({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 10),
        _CardInputField(
          hintText: hint,
          keyboardType: keyboardType,
          textAlign: textAlign,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppTextStyles.style14Medium.copyWith(
        color: colors.onSecondary
      ),
    );
  }
}

class _CardInputField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;

  const _CardInputField({
    required this.hintText,
    this.keyboardType,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return TextFormField(
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 15,
        ),
        filled: true,
        fillColor: colors.onSurface.withValues(alpha: 0.15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none
        ),
      ),
    );
  }
}