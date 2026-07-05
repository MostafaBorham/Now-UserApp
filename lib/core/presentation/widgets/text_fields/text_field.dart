import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// Rounded input that fills grey and turns white with a green border on focus.
class RoundedField extends StatefulWidget {
  const RoundedField({
    super.key,
    this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  State<RoundedField> createState() => _RoundedFieldState();
}

class _RoundedFieldState extends State<RoundedField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder base = OutlineInputBorder(
      borderRadius: AppBorderRadius.brCircular30,
      borderSide: BorderSide.none,
    );
    return TextFormField(
      controller: widget.controller,
      onTapOutside: (event) => _focusNode.unfocus(),
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      style: AppTextStyles.style16Medium.copyWith(color: AppColors.optionTitle),
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: AppColors.fieldFill,
        hintText: widget.hint,
        hintStyle: AppTextStyles.style14Regular.copyWith(
          color: AppColors.mutedLabel,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: base,
        enabledBorder: base,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.brCircular30,
          borderSide: const BorderSide(
            color: AppColors.selectedIndicator,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
