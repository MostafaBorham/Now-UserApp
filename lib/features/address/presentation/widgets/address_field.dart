import 'package:flutter/material.dart';

import '../../../settings/app_colors.dart';

/// A single, label-less rounded input used on the Address Details form.
///
/// Shares the grey fill of the app's other inputs but uses a softer
/// rounded-rectangle radius and shows only placeholder ([hintText]) text.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 16, color: AppColors.hintText),
        ),
      ),
    );
  }
}
