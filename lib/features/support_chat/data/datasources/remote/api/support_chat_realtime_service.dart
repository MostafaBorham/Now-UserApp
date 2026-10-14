import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_realtime_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SupportChatRealtimeService {
  SupportChatRealtimeService({
    required this.onChatChanged,
    required this.onTypingChanged,
    required this.onConnectionChanged,
  });

  static const Duration _handshakeTimeout = Duration(seconds: 10);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  final VoidCallback onChatChanged;
  final ValueChanged<bool> onTypingChanged;
  final ValueChanged<bool> onConnectionChanged;
  final Dio _dio = DioFactory.getDio();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _protocolTimer;
  int _conversationId = 0;
  int _generation = 0;
  int _reconnectAttempt = 0;
  SupportChatRealtimeConfig? _config;
  bool _disposed = false;
  bool _subscribed = false;

  bool get _isConfigured {
    final SupportChatRealtimeConfig? config = _config;
    return config != null &&
        config.enabled &&
        (config.key?.isNotEmpty ?? false) &&
        (config.host?.isNotEmpty ?? false);
  }

  void connect(
    int conversationId, {
    required SupportChatRealtimeConfig config,
  }) {
    _conversationId = conversationId;
    _config = config;
    _disposed = false;
    _generation++;
    _reconnectAttempt = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _protocolTimer?.cancel();
    _protocolTimer = null;
    _closeSocket();
    if (!_isConfigured) {
      debugPrint(
        'Support chat realtime is disabled: REVERB_APP_KEY or REVERB_HOST is missing.',
      );
      onConnectionChanged(false);
      return;
    }
    unawaited(_openSocket(_generation));
  }

  void disconnect() {
    _disposed = true;
    _generation++;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _protocolTimer?.cancel();
    _protocolTimer = null;
    _closeSocket();
    _setSubscribed(false);
    onTypingChanged(false);
  }

  Future<void> _openSocket(int generation) async {
    final SupportChatRealtimeConfig config = _config!;
    final bool secure = config.scheme == 'https';
    final Uri uri = Uri(
      scheme: secure ? 'wss' : 'ws',
      host: config.host!,
      port: config.port,
      path: '/app/${config.key}',
      queryParameters: const <String, String>{
        'protocol': '7',
        'client': 'flutter',
        'version': '1.0',
        'flash': 'false',
      },
    );

    try {
      final WebSocketChannel channel = WebSocketChannel.connect(uri);
      _channel = channel;
      await channel.ready.timeout(_handshakeTimeout);
      if (!_isCurrent(generation)) {
        await channel.sink.close();
        return;
      }
      _armProtocolTimeout(generation, 'connection handshake timed out');
      _subscription = channel.stream.listen(
        (dynamic frame) => _handleFrame(frame, generation),
        onError: (Object error, StackTrace stackTrace) {
          _handleDisconnect(generation, error);
        },
        onDone: () => _handleDisconnect(generation, 'connection closed'),
        cancelOnError: true,
      );
    } on Object catch (error) {
      _handleDisconnect(generation, error);
    }
  }

  void _handleFrame(dynamic frame, int generation) {
    if (!_isCurrent(generation) || frame is! String) return;
    final dynamic decoded;
    try {
      decoded = jsonDecode(frame);
    } on FormatException {
      debugPrint('Support chat realtime received an invalid event frame.');
      return;
    }
    if (decoded is! Map<String, dynamic>) return;

    final dynamic rawEvent = decoded['event'];
    final String? event = rawEvent is String ? rawEvent : null;
    if (event == 'pusher:ping') {
      _sendFrame(<String, dynamic>{'event': 'pusher:pong', 'data': {}});
      return;
    }

    if (event == 'pusher:connection_established') {
      _armProtocolTimeout(generation, 'private channel subscription timed out');
      final dynamic rawData = decoded['data'];
      final dynamic connectionData;
      try {
        connectionData = rawData is String ? jsonDecode(rawData) : rawData;
      } on FormatException {
        _handleDisconnect(generation, 'invalid Pusher connection data');
        return;
      }
      if (connectionData is! Map<String, dynamic> ||
          connectionData['socket_id'] is! String) {
        _handleDisconnect(generation, 'missing Pusher socket ID');
        return;
      }
      unawaited(
        _authorizeAndSubscribe(
          connectionData['socket_id'] as String,
          generation,
        ),
      );
      return;
    }

    if (event == 'pusher_internal:subscription_succeeded') {
      _protocolTimer?.cancel();
      _protocolTimer = null;
      _reconnectAttempt = 0;
      _setSubscribed(true);
      return;
    }

    if (event == 'pusher:subscription_error' || event == 'pusher:error') {
      _handleDisconnect(generation, 'private channel subscription failed');
      return;
    }

    if (event == 'support-chat.message.created' ||
        event == 'support-chat.message.updated' ||
        event == 'support-chat.message.deleted') {
      onChatChanged();
      return;
    }

    if (event == 'support-chat.typing.updated') {
      final dynamic rawData = decoded['data'];
      final dynamic eventData;
      try {
        eventData = rawData is String ? jsonDecode(rawData) : rawData;
      } on FormatException {
        debugPrint('Support chat realtime received invalid typing data.');
        return;
      }
      if (eventData is Map<String, dynamic> &&
          eventData['conversation_id'] == _conversationId &&
          eventData['actor_type'] != 'user' &&
          eventData['is_typing'] is bool) {
        onTypingChanged(eventData['is_typing'] as bool);
      }
    }
  }

  Future<void> _authorizeAndSubscribe(String socketId, int generation) async {
    final String channelName =
        'private-support-chat.conversation.$_conversationId';
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/broadcasting/auth',
        data: <String, String>{
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );
      if (!_isCurrent(generation)) return;
      final dynamic data = response.data;
      if (data is! Map<String, dynamic> || data['auth'] is! String) {
        _handleDisconnect(
          generation,
          'private channel auth response is invalid',
        );
        return;
      }
      _sendFrame(<String, dynamic>{
        'event': 'pusher:subscribe',
        'data': <String, String>{
          'auth': data['auth'] as String,
          'channel': channelName,
        },
      });
    } on DioException catch (error) {
      _handleDisconnect(
        generation,
        'private channel authorization failed: ${error.response?.statusCode ?? error.type.name}',
      );
    } on Object catch (error) {
      _handleDisconnect(generation, error);
    }
  }

  void _sendFrame(Map<String, dynamic> payload) {
    final WebSocketChannel? channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(payload));
    } on Object catch (error) {
      debugPrint('Support chat realtime send failed: $error');
    }
  }

  void _handleDisconnect(int generation, Object error) {
    if (!_isCurrent(generation) || _reconnectTimer != null) return;
    debugPrint('Support chat realtime disconnected: $error');
    _protocolTimer?.cancel();
    _protocolTimer = null;
    _setSubscribed(false);
    onTypingChanged(false);
    _closeSocket();

    final int exponent = _reconnectAttempt < 4 ? _reconnectAttempt : 4;
    final int delaySeconds = 1 << exponent;
    _reconnectAttempt++;
    final Duration delay = Duration(
      seconds: delaySeconds > _maxReconnectDelay.inSeconds
          ? _maxReconnectDelay.inSeconds
          : delaySeconds,
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      if (_isCurrent(generation)) unawaited(_openSocket(generation));
    });
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void _armProtocolTimeout(int generation, String reason) {
    _protocolTimer?.cancel();
    _protocolTimer = Timer(_handshakeTimeout, () {
      _protocolTimer = null;
      _handleDisconnect(generation, reason);
    });
  }

  void _setSubscribed(bool value) {
    if (_subscribed == value) return;
    _subscribed = value;
    onConnectionChanged(value);
  }

  void _closeSocket() {
    _subscription?.cancel();
    _subscription = null;
    final WebSocketChannel? channel = _channel;
    _channel = null;
    if (channel != null) unawaited(channel.sink.close());
  }
}
