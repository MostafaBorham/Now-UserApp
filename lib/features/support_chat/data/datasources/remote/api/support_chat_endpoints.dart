abstract class SupportChatEndpoints {
  static const String conversations = '/api/v1/user/support-chat/conversations';
  static const String realtimeConfig =
      '/api/v1/user/support-chat/realtime-config';

  static String messages(int conversationId) =>
      '$conversations/$conversationId/messages';

  static String syncMessages(int conversationId) =>
      '${messages(conversationId)}/sync';

  static String markAsRead(int conversationId) =>
      '$conversations/$conversationId/read';
}
