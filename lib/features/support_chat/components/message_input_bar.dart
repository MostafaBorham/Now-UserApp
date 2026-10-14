import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Bottom message composer: a rounded text field plus the green send button.
///
/// The send button is drawn straight from `send.svg` (which already includes
/// its own green circle), so it is used as-is.
class MessageInputBar extends StatefulWidget {
  const MessageInputBar({super.key, this.controller, this.onSend});

  final TextEditingController? controller;
  final VoidCallback? onSend;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant MessageInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?.removeListener(_handleTextChanged);
    widget.controller?.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: 15,
      color: context.colors.tertiaryContainer,
    );

    return Container(
      color: context.colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final int lineCount = _lineCount(
                      context,
                      widget.controller?.text ?? '',
                      (constraints.maxWidth - 40).clamp(1, double.infinity),
                      textStyle,
                    );
                    final TextPainter textPainter =
                        TextPainter(
                          text: TextSpan(
                            text: widget.controller?.text ?? ' ',
                            style: textStyle,
                          ),
                          textDirection: Directionality.of(context),
                          textScaler: MediaQuery.textScalerOf(context),
                        )..layout(
                          maxWidth: (constraints.maxWidth - 40).clamp(
                            1,
                            double.infinity,
                          ),
                        );
                    final double fieldHeight =
                        (textPainter.preferredLineHeight * lineCount + 26)
                            .clamp(52, 120)
                            .toDouble();

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: fieldHeight,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: context.colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: context.colors.neutral200),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        minLines: 1,
                        maxLines: lineCount,
                        maxLength: 4000,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => widget.onSend?.call(),
                        textAlignVertical: TextAlignVertical.center,
                        style: textStyle,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          hintText: LangKeys.supportMessageHintKey.tr(),
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: context.colors.neutral500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Part of the field for tap-outside, so sending keeps the
              // keyboard up for the next message.
              TextFieldTapRegion(
                child: GestureDetector(
                  onTap: widget.onSend,
                  child: Assets.media.images.svg.send.svg(
                    width: 52,
                    height: 52,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _lineCount(
    BuildContext context,
    String text,
    double maxWidth,
    TextStyle style,
  ) {
    if (text.isEmpty) return 1;

    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 5,
    )..layout(maxWidth: maxWidth);

    return painter.computeLineMetrics().length.clamp(1, 5);
  }
}
