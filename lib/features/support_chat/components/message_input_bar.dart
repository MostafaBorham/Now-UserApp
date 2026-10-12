import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Bottom message composer: a rounded text field plus the green send button.
///
/// The send button is drawn straight from `send.svg` (which already includes
/// its own green circle), so it is used as-is.
class MessageInputBar extends StatelessWidget {
  const MessageInputBar({super.key, this.controller, this.onSend});

  final TextEditingController? controller;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: context.colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: context.colors.neutral200),
                  ),
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend?.call(),
                    style: TextStyle(
                      fontSize: 15,
                      color: context.colors.tertiaryContainer,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Write Your Message Here..',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: context.colors.neutral500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Part of the field for tap-outside, so sending keeps the
              // keyboard up for the next message.
              TextFieldTapRegion(
                child: GestureDetector(
                  onTap: onSend,
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
}
