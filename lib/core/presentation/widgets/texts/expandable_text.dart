import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    super.key,
    required this.text,
    this.maxCharacters = 200,
    this.style,
    this.seeMoreText = 'See more',
  });

  final String text;
  final int maxCharacters;
  final TextStyle? style;
  final String seeMoreText;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool shouldTrim =
        widget.text.length > widget.maxCharacters && !_expanded;

    return RichText(
      text: TextSpan(
        style: widget.style ?? DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: shouldTrim
                ? '${widget.text.substring(0, widget.maxCharacters)}... '
                : widget.text,
          ),
          if (shouldTrim)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expanded = true;
                  });
                },
                child: Text(
                  widget.seeMoreText,
                  style: (widget.style ?? DefaultTextStyle.of(context).style)
                      .copyWith(
                        color: colors.primary500Main,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}