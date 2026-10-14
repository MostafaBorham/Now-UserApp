class SupportChatMessageModel {
  const SupportChatMessageModel({
    required this.id,
    required this.body,
    required this.isMine,
    required this.createdAt,
  });

  final int id;
  final String body;
  final bool isMine;
  final DateTime? createdAt;

  factory SupportChatMessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException('Support chat message must be an object.');
    }

    final dynamic rawId = json['id'];
    final int? id = rawId is int ? rawId : int.tryParse('$rawId');
    final dynamic rawBody = json['body'];
    final dynamic rawIsMine = json['is_mine'];
    final dynamic rawCreatedAt = json['created_at'];
    final DateTime? createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;

    if (id == null || rawBody is! String || rawIsMine is! bool) {
      throw const FormatException(
        'Support chat message is missing required fields.',
      );
    }

    return SupportChatMessageModel(
      id: id,
      body: rawBody,
      isMine: rawIsMine,
      createdAt: createdAt,
    );
  }
}

class SupportChatSyncModel {
  const SupportChatSyncModel({
    required this.messages,
    required this.deletedMessageIds,
    required this.syncedAt,
  });

  final List<SupportChatMessageModel> messages;
  final List<int> deletedMessageIds;
  final DateTime syncedAt;

  factory SupportChatSyncModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawMessages = json['messages'];
    final dynamic rawDeletedMessages = json['deleted_messages'];
    final dynamic rawMeta = json['meta'];
    final dynamic rawSyncedAt = rawMeta is Map<String, dynamic>
        ? rawMeta['synced_at']
        : null;
    final DateTime? syncedAt = rawSyncedAt is String
        ? DateTime.tryParse(rawSyncedAt)
        : null;

    if (rawMessages is! List ||
        rawDeletedMessages is! List ||
        syncedAt == null) {
      throw const FormatException('Support chat sync response is incomplete.');
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
    );
  }
}
