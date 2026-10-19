import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_message_model.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_realtime_config.dart';

void main() {
  group('SupportChatMessageModel', () {
    test('parses a backend message', () {
      final SupportChatMessageModel message =
          SupportChatMessageModel.fromJson(<String, dynamic>{
            'id': 27,
            'body': 'I need help with my order.',
            'is_mine': false,
            'created_at': '2026-10-14T17:20:00.000000Z',
          });

      expect(message.id, 27);
      expect(message.body, 'I need help with my order.');
      expect(message.isMine, isFalse);
      expect(message.createdAt, DateTime.parse('2026-10-14T17:20:00.000000Z'));
    });

    test('parses delivery driver identity for conversation messages', () {
      final SupportChatMessageModel message = SupportChatMessageModel.fromJson(
        <String, dynamic>{
          'id': 28,
          'body': 'I am on my way.',
          'is_mine': false,
          'created_at': '2026-10-14T17:21:00.000000Z',
          'sender': <String, dynamic>{
            'type': 'delivery_man',
            'name': 'Delivery Driver',
            'avatar_url': '/api/v1/attachments/driver-avatar',
          },
        },
      );

      expect(message.senderType, 'delivery_man');
      expect(message.senderName, 'Delivery Driver');
      expect(message.senderAvatarUrl, '/api/v1/attachments/driver-avatar');
    });

    test('parses a photo-only message and its attachments', () {
      final SupportChatMessageModel message = SupportChatMessageModel.fromJson(
        <String, dynamic>{
          'id': 29,
          'body': null,
          'is_mine': true,
          'created_at': '2026-10-14T17:22:00.000000Z',
          'attachments': <dynamic>[
            <String, dynamic>{
              'original_name': 'receipt.jpg',
              'mime_type': 'image/jpeg',
              'download_url': 'https://api.test/attachments/1/download',
            },
            <String, dynamic>{
              'original_name': 'invoice.pdf',
              'mime_type': 'application/pdf',
              'download_url': 'https://api.test/attachments/2/download',
            },
            // No link: skipped rather than failing the whole page.
            <String, dynamic>{'mime_type': 'image/png', 'download_url': null},
          ],
        },
      );

      expect(message.body, isEmpty);
      expect(message.attachments, hasLength(2));
      expect(message.attachments.first.isImage, isTrue);
      expect(message.attachments.last.isImage, isFalse);
      expect(message.attachments.last.name, 'invoice.pdf');
    });

    test('rejects a response missing required message fields', () {
      expect(
        () => SupportChatMessageModel.fromJson(<String, dynamic>{'id': 27}),
        throwsFormatException,
      );
    });
  });

  group('SupportChatMessagesPage', () {
    test('parses the cursor used to load older conversation messages', () {
      final SupportChatMessagesPage page = SupportChatMessagesPage.fromJson(
        <String, dynamic>{
          'messages': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 27,
              'body': 'Latest message in this page',
              'is_mine': false,
              'created_at': '2026-10-14T17:20:00.000000Z',
            },
          ],
          'meta': <String, dynamic>{
            'has_more': true,
            'next_cursor': 'eyJpZCI6MjcsIl9wb2ludHNUb05leHRJdGVtcyI6dHJ1ZX0',
          },
        },
      );

      expect(page.messages.single.id, 27);
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, isNotEmpty);
    });

    test('allows the last page to have no cursor', () {
      final SupportChatMessagesPage page = SupportChatMessagesPage.fromJson(
        <String, dynamic>{
          'messages': <dynamic>[],
          'meta': <String, dynamic>{'has_more': false, 'next_cursor': null},
        },
      );

      expect(page.messages, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('rejects a page claiming more history without a cursor', () {
      expect(
        () => SupportChatMessagesPage.fromJson(<String, dynamic>{
          'messages': <dynamic>[],
          'meta': <String, dynamic>{'has_more': true, 'next_cursor': null},
        }),
        throwsFormatException,
      );
    });
  });

  group('SupportChatSyncModel', () {
    test('parses changed and deleted messages with the server sync time', () {
      final SupportChatSyncModel sync = SupportChatSyncModel.fromJson(
        <String, dynamic>{
          'messages': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 27,
              'body': 'A reply',
              'is_mine': false,
              'created_at': '2026-10-14T17:20:00.000000Z',
            },
          ],
          'deleted_messages': <Map<String, dynamic>>[
            <String, dynamic>{'id': 26, 'deleted_at': null},
          ],
          'meta': <String, dynamic>{
            'synced_at': '2026-10-14T17:20:15.000000Z',
            'has_more': false,
            'next_cursor': null,
          },
        },
      );

      expect(sync.messages.single.id, 27);
      expect(sync.deletedMessageIds, <int>[26]);
      expect(sync.syncedAt, DateTime.parse('2026-10-14T17:20:15.000000Z'));
      expect(sync.hasMore, isFalse);
      expect(sync.nextCursor, isNull);
    });

    test('parses the conversation closed state', () {
      final SupportChatSyncModel sync = SupportChatSyncModel.fromJson(
        <String, dynamic>{
          'messages': <dynamic>[],
          'deleted_messages': <dynamic>[],
          'meta': <String, dynamic>{
            'synced_at': '2026-10-14T17:20:15.000000Z',
            'has_more': false,
            'next_cursor': null,
            'conversation_is_closed': true,
          },
        },
      );

      expect(sync.conversationIsClosed, isTrue);
    });

    test('parses a continuation cursor when more changes remain', () {
      final SupportChatSyncModel sync = SupportChatSyncModel.fromJson(
        <String, dynamic>{
          'messages': <dynamic>[],
          'deleted_messages': <dynamic>[],
          'meta': <String, dynamic>{
            'synced_at': '2026-10-14T17:20:15.000000Z',
            'has_more': true,
            'next_cursor': 'opaque-sync-cursor',
          },
        },
      );

      expect(sync.hasMore, isTrue);
      expect(sync.nextCursor, 'opaque-sync-cursor');
    });
  });

  group('SupportChatRealtimeConfig', () {
    test('parses the backend Reverb connection settings', () {
      final SupportChatRealtimeConfig config =
          SupportChatRealtimeConfig.fromJson(<String, dynamic>{
            'enabled': true,
            'key': 'public-app-key',
            'host': 'realtime.example.test',
            'scheme': 'https',
            'port': 443,
          });

      expect(config.enabled, isTrue);
      expect(config.key, 'public-app-key');
      expect(config.host, 'realtime.example.test');
      expect(config.port, 443);
    });

    test('allows realtime to be disabled while retaining HTTP polling', () {
      final SupportChatRealtimeConfig config =
          SupportChatRealtimeConfig.fromJson(<String, dynamic>{
            'enabled': false,
            'key': null,
            'host': null,
            'scheme': 'https',
            'port': 443,
          });

      expect(config.enabled, isFalse);
      expect(config.key, isNull);
      expect(config.host, isNull);
    });
  });
}
