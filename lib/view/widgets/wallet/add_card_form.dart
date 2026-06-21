import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';

class AddCardForm extends StatelessWidget {
  const AddCardForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
   gradient: LinearGradient(colors: [colors.onSurfaceVariant,colors.onTertiaryFixedVariant],begin: AlignmentDirectional.centerStart,end: AlignmentDirectional.centerEnd,),
        borderRadius: BorderRadius.circular(16),

        boxShadow: AppBoxShadows.blackElevation1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Card holder'),
          const SizedBox(height: 10),
          const _CardInputField(
            hintText: 'Name ...',
          ),

          const SizedBox(height: 18),

          const _FieldLabel('Card number'),
          const SizedBox(height: 10),
          const _CardInputField(
            hintText: '1111-1111-1111-1111',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 18),

          Row(
            children: const [
              Expanded(
                child: _CardFieldColumn(
                  label: 'CVV',
                  hint: '1**',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _CardFieldColumn(
                  label: 'Expire date',
                  hint: 'Month/Year',
                  keyboardType: TextInputType.datetime,
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
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black,
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
    return SizedBox(
      height: 40,
      child: TextFormField(
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: Colors.black26,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}