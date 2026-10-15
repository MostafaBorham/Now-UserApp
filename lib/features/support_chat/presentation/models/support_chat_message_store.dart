import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/support_chat/components/chat_bubble.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_message_model.dart';

class SupportChatMessageStore {
  SupportChatMessageStore({required this.orderUuid, required this.localeCode});

  final String? orderUuid;
  final String Function() localeCode;
  final List<ChatMessage> messages = [];

  ChatMessage toChatMessage(SupportChatMessageModel message) => ChatMessage(
    id: message.id,
    text: message.body,
    time: message.createdAt == null
        ? ''
        : DateFormat.Hm(localeCode()).format(message.createdAt!.toLocal()),
    createdAt: message.createdAt,
    fromAgent: !message.isMine,
    senderType: message.senderType,
    senderName: message.senderName,
    senderAvatarUrl: message.senderAvatarUrl,
  );

  void merge({
    Iterable<ChatMessage> incoming = const <ChatMessage>[],
    Iterable<int> deletedIds = const <int>[],
    bool replace = false,
  }) {
    final Map<int, ChatMessage> merged = <int, ChatMessage>{};
    if (!replace) {
      for (final ChatMessage message in messages) {
        if (message.id != null) merged[message.id!] = message;
      }
    }
    for (final int id in deletedIds) {
      merged.remove(id);
    }
    for (final ChatMessage message in incoming) {
      if (message.id != null) merged[message.id!] = message;
    }

    final List<ChatMessage> chronological = merged.values.toList()
      ..sort((a, b) => a.id!.compareTo(b.id!));
    messages
      ..clear()
      ..addAll(<ChatMessage>[_welcomeMessage(), ...chronological]);
  }

  ChatMessage _welcomeMessage() =>
      ChatMessage(text: _welcomeMessageText(), time: '', fromAgent: true);

  String _welcomeMessageText() {
    if (orderUuid != null) {
      final String key = LangKeys.driverChatWelcomeMessageKey;
      final String translated = key.tr();
      if (translated != key) return translated;

      return localeCode() == 'ar'
          ? 'هلا بك! 👋\nتقدر تتواصل مع مندوبك من هنا بخصوص طلبك، سواء لتوضيح الموقع أو الاستفسار عن وقت الوصول. حياك الله، ونتمنى لك تجربة توصيل سهلة ومريحة 💚'
          : 'Hi there! 👋\nYou can contact your delivery driver here about your order, whether you need to clarify the location or ask about the arrival time. Welcome, and we hope you have a smooth and pleasant delivery experience 💚';
    }

    final String translated = LangKeys.supportWelcomeMessageKey.tr();
    if (translated != LangKeys.supportWelcomeMessageKey) return translated;

    return localeCode() == 'ar'
        ? 'مرحبًا بك في خدمة عملاء ناو، كيف يمكننا مساعدتك؟'
        : 'Welcome to Now Customer Service. How can we help you?';
  }
}
