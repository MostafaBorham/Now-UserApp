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

    test('rejects a response missing required message fields', () {
      expect(
        () => SupportChatMessageModel.fromJson(<String, dynamic>{'id': 27}),
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
          'meta': <String, dynamic>{'synced_at': '2026-10-14T17:20:15.000000Z'},
        },
      );

      expect(sync.messages.single.id, 27);
      expect(sync.deletedMessageIds, <int>[26]);
      expect(sync.syncedAt, DateTime.parse('2026-10-14T17:20:15.000000Z'));
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
