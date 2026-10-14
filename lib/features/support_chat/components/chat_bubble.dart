import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    this.fromAgent = false,
    this.id,
    this.createdAt,
    this.senderType,
    this.senderName,
    this.senderAvatarUrl,
  });

  final int? id;
  final String text;
  final String time;
  final bool fromAgent;
  final DateTime? createdAt;
  final String? senderType;
  final String? senderName;
  final String? senderAvatarUrl;
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, this.userAvatarUrl});

  final ChatMessage message;
  final String? userAvatarUrl;

  static const double _avatar = 42;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final bool agent = message.fromAgent;

    final Widget bubble = Flexible(
      child: Column(
        crossAxisAlignment: agent
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (agent && (message.senderName?.trim().isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: 4,
                start: 4,
                end: 4,
              ),
              child: Text(
                message.senderName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: agent
                  ? context.colors.onPrimaryContainer
                  : context.colors.primary500Main,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w400,
                color: agent
                    ? context.colors.tertiaryContainer
                    : context.colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    final Widget avatar = !agent
        ? _PersonAvatar(size: _avatar, imageUrl: userAvatarUrl)
        : message.senderType == 'delivery_man'
        ? _PersonAvatar(size: _avatar, imageUrl: message.senderAvatarUrl)
        : const _NowAvatar(size: _avatar);

    return Column(
      crossAxisAlignment: agent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: agent
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
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
            style: TextStyle(fontSize: 12, color: context.colors.neutral500),
          ),
        ),
      ],
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({required this.size, this.imageUrl});

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String token = TokenCacheService().getAccessToken() ?? '';
    final String url = imageUrl?.trim() ?? '';
    final Widget placeholder = Assets.media.images.png.userAvatarPlaceholderImg
        .image(width: size, height: size, fit: BoxFit.cover);

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: url.isEmpty || token.isEmpty
            ? placeholder
            : AppCachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                placeholderType: LoadingViewTypes.shimmer,
                loadingPlaceholder: placeholder,
                httpHeaders: <String, String>{'Authorization': 'Bearer $token'},
              ),
      ),
    );
  }
}

class _NowAvatar extends StatelessWidget {
  const _NowAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.onPrimaryContainer,
      ),
      child: Assets.media.images.svg.logoHorizontal.svg(width: 26),
    );
  }
}
