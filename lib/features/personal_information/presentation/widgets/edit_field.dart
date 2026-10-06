import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/focus_ring.dart';

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
    this.errorText,
    this.inputFormatters,
    this.textDirection,
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

  /// Validation message shown under the pill, which also turns red. Null when
  /// the field is valid.
  final String? errorText;

  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelRow(context),
        const SizedBox(height: 8),
        _pill(context),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Text(
              errorText!,
              style: TextStyle(fontSize: 12, color: context.colors.red300Main),
            ),
          ),
        ],
      ],
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
            // The pill is a fixed 54px: without this a long value wraps to a
            // second line and overflows it.
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            inputFormatters: inputFormatters,
            textDirection: textDirection,
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

    final Widget box = Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: errorText == null
            ? null
            : Border.all(color: context.colors.red300Main),
      ),
      child: Row(children: children),
    );
    final Widget pill = readOnly
        ? box
        : FocusRing(borderRadius: BorderRadius.circular(999), child: box);

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
