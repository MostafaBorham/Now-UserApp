import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import '../../settings/app_colors.dart';

/// A single chat message.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    this.fromAgent = false,
  });

  final String text;
  final String time;

  /// true → the "now" support agent (grey bubble, right, logo avatar);
  /// false → the customer (green bubble, left, photo avatar).
  final bool fromAgent;
}

/// One message row: avatar + bubble on a line, timestamp beneath.
///
/// Customer messages sit on the left with the person photo; agent ("now")
/// messages sit on the right with the brand-logo avatar.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  static const double _avatar = 42;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final bool agent = message.fromAgent;

    final Widget bubble = Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: agent ? AppColors.inputFill : AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            fontWeight: agent ? FontWeight.w400 : FontWeight.w500,
            color: agent ? AppColors.textPrimary : AppColors.buttonForeground,
          ),
        ),
      ),
    );

    final Widget avatar = agent
        ? const _NowAvatar(size: _avatar)
        : const _PersonAvatar(size: _avatar);

    return Column(
      crossAxisAlignment:
          agent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              agent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: agent
              ? [bubble, const SizedBox(width: _gap), avatar]
              : [avatar, const SizedBox(width: _gap), bubble],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: agent
              ? const EdgeInsets.only(right: _avatar + _gap)
              : const EdgeInsets.only(left: _avatar + _gap),
          child: Text(
            message.time,
            style: const TextStyle(fontSize: 12, color: AppColors.hintText),
          ),
        ),
      ],
    );
  }
}

/// Circular customer photo.
class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Assets.media.images.svg.personPng.image(
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Circular "now" brand avatar used for agent messages.
class _NowAvatar extends StatelessWidget {
  const _NowAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey,
      ),
      child: Assets.media.images.svg.logoHorizontal.svg(width: 26),
    );
  }
}
