import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/support_chat/components/chat_bubble.dart';
import 'package:nowdelivery_user_app/features/support_chat/components/message_input_bar.dart';

class SupportChatView extends StatelessWidget {
  const SupportChatView({
    super.key,
    required this.title,
    required this.onClose,
    required this.messages,
    required this.scrollController,
    required this.onRefresh,
    required this.initialScrollPositioned,
    required this.isLoadingOlderMessages,
    required this.typingActorType,
    required this.isConversationClosed,
    required this.inputController,
    required this.isSending,
    required this.onSend,
    required this.onAttach,
    required this.photos,
    required this.onRemovePhoto,
    this.userAvatarUrl,
  });

  final String title;
  final VoidCallback? onClose;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final bool initialScrollPositioned;
  final bool isLoadingOlderMessages;
  final String? typingActorType;
  final bool isConversationClosed;
  final TextEditingController inputController;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final List<String> photos;
  final ValueChanged<int> onRemovePhoto;
  final String? userAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: colors.white,
      body: AppWavedView(
        appBarTitle: title,
        leading: onClose == null
            ? const SizedBox.shrink()
            : InkWell(
                onTap: onClose,
                child: CircleAvatar(
                  backgroundColor: colors.white,
                  radius: screenSize.width * 0.05,
                  child: Center(
                    child: Assets.media.images.svg.closeSquareIcon.svg(
                      fit: BoxFit.contain,
                      width: screenSize.width * 0.05,
                    ),
                  ),
                ),
              ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Opacity(
                    opacity: initialScrollPositioned ? 1 : 0,
                    child: AppRefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.separated(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.manual,
                        itemCount: messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 18),
                        itemBuilder: (context, index) => KeyedSubtree(
                          key: ValueKey<String>(
                            messages[index].id == null
                                ? 'support-chat-welcome'
                                : 'support-chat-${messages[index].id}',
                          ),
                          child: ChatBubble(
                            message: messages[index],
                            userAvatarUrl: userAvatarUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!initialScrollPositioned)
                    Center(
                      child: CircularProgressIndicator(
                        color: colors.primary500Main,
                      ),
                    ),
                  if (isLoadingOlderMessages)
                    PositionedDirectional(
                      top: 8,
                      start: 0,
                      end: 0,
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary500Main,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (typingActorType != null && !isConversationClosed)
              Container(
                margin: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    (typingActorType == 'delivery_man'
                            ? LangKeys.driverTypingIndicatorKey
                            : LangKeys.supportTypingIndicatorKey)
                        .tr(),
                    style: TextStyle(fontSize: 12, color: colors.neutral500),
                  ),
                ),
              ),
            if (isConversationClosed)
              Container(
                width: double.infinity,
                margin: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  LangKeys.chatClosedMessageKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.tertiaryContainer,
                  ),
                ),
              )
            else
              MessageInputBar(
                controller: inputController,
                onSend: isSending ? null : onSend,
                onAttach: onAttach,
                photos: photos,
                onRemovePhoto: onRemovePhoto,
              ),
          ],
        ),
      ),
    );
  }
}
