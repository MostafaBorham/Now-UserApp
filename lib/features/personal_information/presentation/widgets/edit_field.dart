import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// A labelled, editable field on the Edit Information screen.
///
/// Renders a grey label (with an optional live character counter) above a
/// rounded input "pill". The pill can hold a leading and/or trailing SVG icon
/// around either a [TextField] (default) or, when [onTap] is provided with
/// [readOnly] set, tappable display text (used for the date picker).
class EditField extends StatelessWidget {
  const EditField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.leadingAsset,
    this.trailingAsset,
    this.keyboardType,
    this.maxLength,
    this.showCounter = false,
    this.onTap,
    this.readOnly = false,
    this.valueText,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? leadingAsset;
  final String? trailingAsset;
  final TextInputType? keyboardType;
  final int? maxLength;

  /// Shows a live "current/max" counter on the right of the label.
  final bool showCounter;

  /// When set, the pill becomes tappable (e.g. to open a date picker).
  final VoidCallback? onTap;

  /// When true the pill shows [valueText]/[hintText] instead of a [TextField].
  final bool readOnly;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_labelRow(context), const SizedBox(height: 8), _pill(context)],
    );
  }

  Widget _labelRow(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 13,
      color: context.colors.neutral500,
    );
    if (!showCounter || controller == null) {
      return Text(label, style: labelStyle);
    }
    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller!,
          builder: (context, value, _) =>
              Text('${value.text.length}/${maxLength ?? 0}', style: labelStyle),
        ),
      ],
    );
  }

  Widget _pill(BuildContext context) {
    final List<Widget> children = [];

    if (leadingAsset != null) {
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: SvgPicture.asset(leadingAsset!, width: 20, height: 20),
        ),
      );
    }

    if (readOnly) {
      final bool hasValue = valueText != null && valueText!.isNotEmpty;
      children.add(
        Expanded(
          child: Text(
            hasValue ? valueText! : (hintText ?? ''),
            style: TextStyle(
              fontSize: 16,
              color: hasValue
                  ? context.colors.tertiaryContainer
                  : context.colors.neutral500,
            ),
          ),
        ),
      );
    } else {
      children.add(
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            buildCounter:
                (
                  BuildContext context, {
                  required int currentLength,
                  required int? maxLength,
                  required bool isFocused,
                }) => null,
            style: TextStyle(
              fontSize: 16,
              color: context.colors.tertiaryContainer,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 16,
                color: context.colors.neutral500,
              ),
            ),
          ),
        ),
      );
    }

    if (trailingAsset != null) {
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: SvgPicture.asset(trailingAsset!, width: 20, height: 20),
        ),
      );
    }

    final Widget pill = Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(children: children),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: pill,
      );
    }
    return pill;
  }
}
