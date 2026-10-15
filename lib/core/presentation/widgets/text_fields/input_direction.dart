import 'package:flutter/material.dart';

/// Right-to-left scripts this app can receive: Hebrew, Arabic and its
/// supplements/presentation forms. Minor RTL scripts (Thaana, NKo, …) are left
/// out on purpose.
bool _isRtlRune(int rune) =>
    (rune >= 0x0590 && rune <= 0x05FF) || // Hebrew
    ((rune >= 0x0600 && rune <= 0x06FF) && !_isWeakArabicRune(rune)) || // Arabic
    (rune >= 0x0750 && rune <= 0x077F) || // Arabic Supplement
    (rune >= 0x08A0 && rune <= 0x08FF) || // Arabic Extended-A
    (rune >= 0xFB1D && rune <= 0xFDFF) || // Hebrew / Arabic Presentation Forms-A
    (rune >= 0xFE70 && rune <= 0xFEFF); // Arabic Presentation Forms-B

/// Left-to-right letters: ASCII and the Latin-1/Latin Extended ranges. The app
/// ships Arabic and English only, so any other script falls through to `null`.
bool _isLtrRune(int rune) =>
    (rune >= 0x0041 && rune <= 0x005A) ||
    (rune >= 0x0061 && rune <= 0x007A) ||
    (rune >= 0x00C0 && rune <= 0x024F);

/// Decimal digits, ASCII and both Arabic sets.
///
/// Numerals are weak in the bidi algorithm: "٥٠" in an English field must no
/// more flip it to RTL than "50" would, even though the Arabic-Indic digits
/// live inside the Arabic block that [_isRtlRune] scans.
bool _isDigit(int rune) =>
    (rune >= 0x0030 && rune <= 0x0039) || // 0-9
    (rune >= 0x0660 && rune <= 0x0669) || // ٠-٩ Arabic-Indic
    (rune >= 0x06F0 && rune <= 0x06F9); // ۰-۹ Extended Arabic-Indic

/// Codepoints inside the Arabic block that are numerals or punctuation —
/// weak or neutral in the bidi algorithm, so like ASCII digits they must not
/// decide the field's direction on their own.
bool _isWeakArabicRune(int rune) =>
    _isDigit(rune) ||
    (rune >= 0x0600 && rune <= 0x0605) || // currency / number signs
    rune == 0x060C || // ،
    rune == 0x061B || // ؛
    rune == 0x061F || // ؟
    rune == 0x066B || // ٫
    rune == 0x066C; // ٬

/// Writing direction for text the user is entering, in the spirit of the
/// browser's `dir="auto"`: the first strong character decides.
///
/// * an Arabic or Hebrew character → [TextDirection.rtl]
/// * a Latin letter → [TextDirection.ltr]
/// * nothing strong yet — empty field, digits, spaces or punctuation only →
///   `null`, so the field keeps the locale's direction, which is also the
///   direction its localized hint is laid out in.
TextDirection? resolveInputDirection(String? text) {
  if (text == null) return null;
  for (final int rune in text.runes) {
    if (_isRtlRune(rune)) return TextDirection.rtl;
    if (_isLtrRune(rune)) return TextDirection.ltr;
  }
  return null;
}

/// Rebuilds [builder] with the direction of [controller]'s current text, so a
/// field flips between LTR and RTL as the user switches language. It only
/// rebuilds when the direction actually changes, not on every keystroke.
///
/// Wrap borderless and decorated fields alike; callers that must pin a
/// direction (email, phone, card numbers) should prefer their own fixed
/// [TextDirection] over the one handed to [builder].
class InputDirectionBuilder extends StatefulWidget {
  const InputDirectionBuilder({
    super.key,
    required this.controller,
    required this.builder,
  });

  /// The field's controller. When `null` there is no text to inspect, so the
  /// resolved direction stays `null` (the locale's).
  final TextEditingController? controller;

  /// Builds the field with the resolved direction.
  final Widget Function(BuildContext context, TextDirection? direction)
  builder;

  @override
  State<InputDirectionBuilder> createState() => _InputDirectionBuilderState();
}

class _InputDirectionBuilderState extends State<InputDirectionBuilder> {
  TextDirection? _direction;

  @override
  void initState() {
    super.initState();
    _direction = resolveInputDirection(widget.controller?.text);
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant InputDirectionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
      _direction = resolveInputDirection(widget.controller?.text);
    }
  }

  void _onTextChanged() {
    final TextDirection? next = resolveInputDirection(widget.controller?.text);
    if (next != _direction) setState(() => _direction = next);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _direction);
}
