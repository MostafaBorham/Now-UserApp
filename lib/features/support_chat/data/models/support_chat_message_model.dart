/// A file on a message. [url] is the authenticated download route, so loading
/// it needs the bearer token.
class SupportChatAttachmentModel {
  const SupportChatAttachmentModel({
    required this.url,
    required this.name,
    required this.isImage,
  });

  final String url;
  final String name;
  final bool isImage;

  /// Null for an entry without a download link: one unusable file mustn't
  /// fail the whole page of messages.
  static SupportChatAttachmentModel? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final dynamic url = json['download_url'];
    if (url is! String || url.isEmpty) return null;
    final dynamic name = json['original_name'];
    final dynamic mimeType = json['mime_type'];
    return SupportChatAttachmentModel(
      url: url,
      name: name is String ? name : '',
      isImage: mimeType is String && mimeType.startsWith('image/'),
    );
  }
}

class SupportChatMessageModel {
  const SupportChatMessageModel({
    required this.id,
    required this.body,
    required this.isMine,
    required this.createdAt,
    this.senderType,
    this.senderName,
    this.senderAvatarUrl,
    this.attachments = const <SupportChatAttachmentModel>[],
  });

  final int id;
  final String body;
  final bool isMine;
  final DateTime? createdAt;
  final String? senderType;
  final String? senderName;
  final String? senderAvatarUrl;
  final List<SupportChatAttachmentModel> attachments;

  factory SupportChatMessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException('Support chat message must be an object.');
    }

    final dynamic rawId = json['id'];
    final int? id = rawId is int ? rawId : int.tryParse('$rawId');
    final dynamic rawBody = json['body'];
    final dynamic rawIsMine = json['is_mine'];
    final dynamic rawCreatedAt = json['created_at'];
    final dynamic rawSender = json['sender'];
    final dynamic rawAttachments = json['attachments'];
    final DateTime? createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;

    // A photo-only message comes back with a null body.
    if (id == null ||
        (rawBody != null && rawBody is! String) ||
        rawIsMine is! bool) {
      throw const FormatException(
        'Support chat message is missing required fields.',
      );
    }

    return SupportChatMessageModel(
      id: id,
      body: rawBody is String ? rawBody : '',
      isMine: rawIsMine,
      createdAt: createdAt,
      senderType:
          rawSender is Map<String, dynamic> && rawSender['type'] is String
          ? rawSender['type'] as String
          : null,
      senderName:
          rawSender is Map<String, dynamic> && rawSender['name'] is String
          ? rawSender['name'] as String
          : null,
      senderAvatarUrl:
          rawSender is Map<String, dynamic> && rawSender['avatar_url'] is String
          ? rawSender['avatar_url'] as String
          : null,
      attachments: rawAttachments is List
          ? rawAttachments
                .map(SupportChatAttachmentModel.fromJson)
                .whereType<SupportChatAttachmentModel>()
                .toList()
          : const <SupportChatAttachmentModel>[],
    );
  }
}

class SupportChatMessagesPage {
  const SupportChatMessagesPage({
    required this.messages,
    required this.hasMore,
    required this.nextCursor,
  });

  final List<SupportChatMessageModel> messages;
  final bool hasMore;
  final String? nextCursor;

  factory SupportChatMessagesPage.fromJson(Map<String, dynamic> json) {
    final dynamic rawMessages = json['messages'];
    final dynamic rawMeta = json['meta'];
    final dynamic rawHasMore = rawMeta is Map<String, dynamic>
        ? rawMeta['has_more']
        : null;
    final dynamic rawCursor = rawMeta is Map<String, dynamic>
        ? rawMeta['next_cursor']
        : null;

    if (rawMessages is! List || rawHasMore is! bool) {
      throw const FormatException('Support chat message page is incomplete.');
    }
    if (rawHasMore && (rawCursor is! String || rawCursor.isEmpty)) {
      throw const FormatException(
        'Support chat message page is missing its next cursor.',
      );
    }

    return SupportChatMessagesPage(
      messages: rawMessages
          .map(
            (dynamic item) => SupportChatMessageModel.fromJson(
              item is Map<String, dynamic> ? item : null,
            ),
          )
          .toList(),
      hasMore: rawHasMore,
      nextCursor: rawCursor is String && rawCursor.isNotEmpty
          ? rawCursor
          : null,
    );
  }
}

class SupportChatSyncModel {
  const SupportChatSyncModel({
    required this.messages,
    required this.deletedMessageIds,
    required this.syncedAt,
    required this.hasMore,
    required this.nextCursor,
    this.conversationIsClosed,
  });

  final List<SupportChatMessageModel> messages;
  final List<int> deletedMessageIds;
  final DateTime syncedAt;
  final bool hasMore;
  final String? nextCursor;
  final bool? conversationIsClosed;

  factory SupportChatSyncModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawMessages = json['messages'];
    final dynamic rawDeletedMessages = json['deleted_messages'];
    final dynamic rawMeta = json['meta'];
    final dynamic rawSyncedAt = rawMeta is Map<String, dynamic>
        ? rawMeta['synced_at']
        : null;
    final dynamic rawHasMore = rawMeta is Map<String, dynamic>
        ? rawMeta['has_more']
        : null;
    final dynamic rawCursor = rawMeta is Map<String, dynamic>
        ? rawMeta['next_cursor']
        : null;
    final dynamic rawConversationIsClosed = rawMeta is Map<String, dynamic>
        ? rawMeta['conversation_is_closed']
        : null;
    final DateTime? syncedAt = rawSyncedAt is String
        ? DateTime.tryParse(rawSyncedAt)
        : null;

    if (rawMessages is! List ||
        rawDeletedMessages is! List ||
        syncedAt == null ||
        rawHasMore is! bool) {
      throw const FormatException('Support chat sync response is incomplete.');
    }
    if (rawHasMore && (rawCursor is! String || rawCursor.isEmpty)) {
      throw const FormatException(
        'Support chat sync response is missing its next cursor.',
      );
    }

    final List<int> deletedMessageIds = rawDeletedMessages.map((dynamic item) {
      final dynamic rawId = item is Map<String, dynamic> ? item['id'] : null;
      final int? id = rawId is int ? rawId : int.tryParse('$rawId');
      if (id == null) {
        throw const FormatException('Deleted support chat message has no ID.');
      }
      return id;
    }).toList();

    return SupportChatSyncModel(
      messages: rawMessages
          .map(
            (dynamic item) => SupportChatMessageModel.fromJson(
              item is Map<String, dynamic> ? item : null,
            ),
          )
          .toList(),
      deletedMessageIds: deletedMessageIds,
      syncedAt: syncedAt,
      hasMore: rawHasMore,
      nextCursor: rawCursor is String && rawCursor.isNotEmpty
          ? rawCursor
          : null,
      conversationIsClosed: rawConversationIsClosed is bool
          ? rawConversationIsClosed
          : null,
    );
  }
}
