import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../settings/app_colors.dart';

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
      color: AppColors.background,
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
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend?.call(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Write Your Message Here..',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: AppColors.hintText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSend,
                child: SvgPicture.asset(
                  'assets/svg/send.svg',
                  width: 52,
                  height: 52,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
