import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// The compact, filled comment box the rating screen puts under every rateable
/// row. It grows from one line up to four as the shopper types and takes its
/// [fillColor] from the caller — white inside the products card, a neutral grey
/// for the courier and store sections. An editable box takes at most
/// [maxLength] characters and counts them underneath, and lets through only
/// [inputFormatters]' text; a read-only one shows a submitted comment as it is.
class RatingCommentField extends StatelessWidget {
  /// The product's limit; the backend itself accepts up to 1000.
  static const int maxLength = 400;

  /// What can be typed or pasted, applied in order:
  ///
  /// 1. Letters of any script with their marks (Arabic diacritics), digits,
  ///    spaces, line breaks and everyday punctuation — Arabic marks and the
  ///    curly quotes and dashes iOS substitutes included. Symbols (`*`, `+`,
  ///    `#`, `_`, …), emoji and the decorative tatweel never reach the box.
  /// 2. The same character at most three times in a row: `-------` stays
  ///    `---`, `حلووووو` stays `حلووو`. Digits are exempt, so `10000` is kept.
  /// 3. At most three punctuation marks in a row: `!?!?!?` stays `!?!`.
  static final List<TextInputFormatter> inputFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(
      RegExp(
        r'''(?!ـ)[\p{L}\p{M}\p{Nd} \n.,!?'"()\-:;/%&،؛؟٪٫٬…‘’“”«»–—]''',
        unicode: true,
      ),
    ),
    FilteringTextInputFormatter.deny(
      RegExp(r'(\P{Nd})(?=\1{3})', unicode: true),
    ),
    FilteringTextInputFormatter.deny(
      RegExp(
        r'(?<=[^\p{L}\p{M}\p{Nd}\s]{3})[^\p{L}\p{M}\p{Nd}\s]',
        unicode: true,
      ),
    ),
  ];

  static final RegExp _letter = RegExp(r'[\p{L}\p{M}]', unicode: true);
  static final RegExp _word = RegExp(r'\p{L}\p{M}*\p{L}', unicode: true);
  static final RegExp _repeatedChunk = RegExp(r'(.{2,}?)\1{3}', unicode: true);

  /// Whether [comment] reads as words rather than filler — what the typing
  /// rules alone can't stop. An empty comment is fine (it's optional);
  /// otherwise it needs a word of two letters or more, letters must make up at
  /// least half of what isn't a space (`- - - - ok` fails), and no stretch of
  /// it may repeat four times running (`hahahaha`, `abcabcabcabc`).
  static bool isReadable(String comment) {
    final String text = comment.trim();
    if (text.isEmpty) return true;
    final int visible = text.replaceAll(RegExp(r'\s'), '').runes.length;
    return _word.hasMatch(text) &&
        _letter.allMatches(text).length * 2 >= visible &&
        !_repeatedChunk.hasMatch(text);
  }

  const RatingCommentField({
    super.key,
    required this.hint,
    this.controller,
    this.fillColor,
    this.readOnly = false,
  });

  final String hint;
  final TextEditingController? controller;
  final Color? fillColor;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final InputBorder border = OutlineInputBorder(
      borderRadius: AppBorderRadius.brCircular6,
      borderSide: const BorderSide(color: Colors.transparent),
    );

    return InputDirectionBuilder(
      controller: controller,
      builder: (BuildContext context, TextDirection? typedDirection) =>
          TextField(
            contextMenuBuilder: appContextMenuBuilder,
            controller: controller,
            readOnly: readOnly,
            maxLength: readOnly ? null : maxLength,
            inputFormatters: readOnly ? null : inputFormatters,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            textDirection: typedDirection,
            style: AppTextStyles.style14Regular.copyWith(color: colors.black),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: fillColor ?? colors.white,
              hintText: hint,
              hintStyle: AppTextStyles.style14Regular.copyWith(
                color: colors.neutral400,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: border,
              enabledBorder: border,
              focusedBorder: readOnly
                  ? border
                  : border.copyWith(
                      borderSide: BorderSide(
                        color: colors.primary500Main,
                        width: 1.5,
                      ),
                    ),
            ),
          ),
    );
  }
}
