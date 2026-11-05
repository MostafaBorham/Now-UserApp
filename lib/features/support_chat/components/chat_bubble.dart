import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/full_screen_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_message_model.dart';

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
    this.attachments = const <SupportChatAttachmentModel>[],
  });

  final int? id;
  final String text;
  final String time;
  final bool fromAgent;
  final DateTime? createdAt;
  final String? senderType;
  final String? senderName;
  final String? senderAvatarUrl;
  final List<SupportChatAttachmentModel> attachments;
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
    final Color textColor = agent
        ? context.colors.tertiaryContainer
        : context.colors.white;
    final List<String> imageUrls = <String>[
      for (final SupportChatAttachmentModel attachment in message.attachments)
        if (attachment.isImage) attachment.url,
    ];

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (imageUrls.isNotEmpty) _AttachmentGrid(urls: imageUrls),
                for (final SupportChatAttachmentModel attachment
                    in message.attachments)
                  if (!attachment.isImage)
                    // The backend only accepts images and PDFs, so anything
                    // else is a PDF: opened in the app's viewer.
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.pushNamed(
                          AppRoutes.pdfViewerScreen,
                          extra: (url: attachment.url, title: attachment.name),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 6,
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 18,
                              color: textColor,
                            ),
                            Flexible(
                              child: Text(
                                attachment.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  decoration: TextDecoration.underline,
                                  decorationColor: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
              ],
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

/// A message's photos, loaded through the authenticated download route. One
/// alone is a square up to 200 px; more sit two to a row as squares, an odd
/// last one spanning the row. A tap opens that photo full screen.
class _AttachmentGrid extends StatelessWidget {
  const _AttachmentGrid({required this.urls});

  final List<String> urls;

  static const double _maxWidth = 200;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer ${TokenCacheService().getAccessToken() ?? ''}',
    };
    final int count = urls.length;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Whole pixels, so two halves plus the gap never overshoot the row
        // and wrap.
        final double width = math
            .min(_maxWidth, constraints.maxWidth)
            .floorToDouble();
        final double half = (width - _gap) / 2;
        final double height = count == 1 ? width : half;
        return SizedBox(
          width: width,
          child: Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (int i = 0; i < count; i++)
                // Held to its size: once loaded, AppCachedNetworkImage
                // centres itself in all the width it's offered and would fill
                // the row alone.
                SizedBox(
                  width: count.isOdd && i == count - 1 ? width : half,
                  height: height,
                  child: GestureDetector(
                    // The loading shimmer doesn't hit-test; the whole tile
                    // should.
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showFullScreenNetworkImage(
                      context,
                      urls[i],
                      httpHeaders: headers,
                    ),
                    child: ClipRRect(
                      borderRadius: AppBorderRadius.brCircular12,
                      child: AppCachedNetworkImage(
                        imageUrl: urls[i],
                        width: count.isOdd && i == count - 1 ? width : half,
                        height: height,
                        httpHeaders: headers,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
