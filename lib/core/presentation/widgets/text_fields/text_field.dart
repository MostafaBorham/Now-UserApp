import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Rounded input that fills grey and turns white with a green border on focus.
class RoundedField extends StatefulWidget {
  const RoundedField({
    super.key,
    this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.textDirection,
  });

  final TextEditingController? controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;

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
      inputFormatters: widget.inputFormatters,
      textDirection: widget.textDirection,
      style: AppTextStyles.style16Medium.copyWith(
        color: context.colors.tertiaryContainer,
      ),
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: context.colors.onPrimaryContainer,
        hintText: widget.hint,
        hintStyle: AppTextStyles.style14Regular.copyWith(
          color: context.colors.neutral500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: base,
        enabledBorder: base,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.brCircular30,
          borderSide: BorderSide(
            color: context.colors.primary500Main,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
