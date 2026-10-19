import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/utils/idempotency_key.dart';
import 'package:nowdelivery_user_app/features/support_chat/components/chat_bubble.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/datasources/remote/api/support_chat_realtime_service.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_message_model.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_realtime_config.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/repo/support_chat_repo.dart';
import 'package:nowdelivery_user_app/features/support_chat/presentation/models/support_chat_message_store.dart';

class SupportChatController extends ChangeNotifier {
  SupportChatController({
    required this.orderUuid,
    required this.localeCode,
    required this.showError,
    SupportChatRepo? repository,
  }) : _repo = repository ?? SupportChatRepo(),
       _messageStore = SupportChatMessageStore(
         orderUuid: orderUuid,
         localeCode: localeCode,
       ) {
    _realtimeService = SupportChatRealtimeService(
      onChatChanged: _handleRealtimeChatChange,
      onTypingChanged: _onTypingChanged,
      onConversationClosed: _onConversationClosed,
      onConnectionChanged: _onRealtimeConnectionChanged,
    );
    scroll.addListener(_handleScroll);
  }

  static const Duration _pollInterval = Duration(seconds: 15);
  static const Duration _realtimeFallbackInterval = Duration(seconds: 60);

  /// The server's cap on attachments per message.
  static const int maxPhotos = 10;

  final String? orderUuid;
  final String Function() localeCode;
  final void Function(String message) showError;
  final SupportChatRepo _repo;
  final SupportChatMessageStore _messageStore;
  final IdempotencyKey _sendIdempotencyKey = IdempotencyKey();
  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  /// Paths of the photos waiting to go with the next message.
  final List<String> photos = <String>[];

  late final SupportChatRealtimeService _realtimeService;
  Timer? _pollTimer;
  Timer? _typingIndicatorTimer;
  int? _conversationId;
  DateTime _lastSyncedAt = DateTime.now().toUtc().subtract(
    const Duration(seconds: 1),
  );
  bool isLoading = true;
  bool messagesLoaded = false;
  bool isSending = false;
  bool isRefreshing = false;
  bool isLoadingOlderMessages = false;
  bool initialScrollPositioned = false;
  bool isConversationClosed = false;
  bool _isSyncing = false;
  bool _hasReportedSyncFailure = false;
  bool _realtimeConnected = false;
  bool _isForeground = true;
  bool _hasReportedRealtimeConfigFailure = false;
  bool _hasQueuedRealtimeSync = false;
  bool _hasMoreOlderMessages = false;
  bool _hasLoadedOlderMessages = false;
  bool _disposed = false;
  String? typingActorType;
  String? _olderMessagesCursor;

  List<ChatMessage> get messages => _messageStore.messages;

  Future<void> initialize() async {
    final Either<Failure, int> conversationResult = orderUuid == null
        ? await _repo.openConversation()
        : await _repo.openOrderDriverConversation(orderUuid!);
    if (_disposed) return;

    final int? conversationId = conversationResult.fold((failure) {
      showError(failure.message);
      return null;
    }, (id) => id);
    if (conversationId == null) {
      isLoading = false;
      initialScrollPositioned = true;
      notifyListeners();
      return;
    }

    _conversationId = conversationId;
    await _loadInitialMessages();
    if (!_disposed && !isConversationClosed) {
      unawaited(_loadRealtimeConfig(conversationId));
      _startPolling();
    }
  }

  void onResumed() {
    _isForeground = true;
    final int? conversationId = _conversationId;
    if (conversationId != null && !isConversationClosed) {
      unawaited(_loadRealtimeConfig(conversationId));
    }
    _startPolling();
  }

  void onPaused() {
    _isForeground = false;
    _pollTimer?.cancel();
    _typingIndicatorTimer?.cancel();
    _realtimeService.disconnect();
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _typingIndicatorTimer?.cancel();
    scroll.removeListener(_handleScroll);
    _realtimeService.disconnect();
    _repo.cancelRequests();
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> refreshMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null || isLoading || isRefreshing) return;

    isRefreshing = true;
    Either<Failure, SupportChatMessagesPage> result;
    try {
      result = await _repo.getMessages(conversationId);
    } finally {
      isRefreshing = false;
    }
    final bool shouldSyncAgain = _hasQueuedRealtimeSync;
    _hasQueuedRealtimeSync = false;
    if (_disposed) return;

    result.fold((failure) => showError(failure.message), (page) {
      if (!_hasLoadedOlderMessages) {
        _olderMessagesCursor = page.nextCursor;
        _hasMoreOlderMessages = page.hasMore;
      }
      _messageStore.merge(
        incoming: page.messages.map(_messageStore.toChatMessage),
      );
      messagesLoaded = true;
      _markConversationAsRead(conversationId);
    });
    notifyListeners();
    if (shouldSyncAgain) unawaited(_syncMessages());
  }

  void _handleScroll() {
    if (scroll.hasClients &&
        initialScrollPositioned &&
        scroll.position.pixels <= 80 &&
        _hasMoreOlderMessages &&
        !isLoadingOlderMessages &&
        !isRefreshing &&
        !isLoading) {
      unawaited(_loadOlderMessages());
    }
  }

  Future<void> _loadOlderMessages() async {
    final int? conversationId = _conversationId;
    final String? cursor = _olderMessagesCursor;
    if (conversationId == null ||
        cursor == null ||
        !_hasMoreOlderMessages ||
        isLoadingOlderMessages) {
      return;
    }

    isLoadingOlderMessages = true;
    notifyListeners();
    final double oldPixels = scroll.hasClients ? scroll.position.pixels : 0;
    final double oldMaxExtent = scroll.hasClients
        ? scroll.position.maxScrollExtent
        : 0;
    Either<Failure, SupportChatMessagesPage> result;
    try {
      result = await _repo.getMessages(conversationId, cursor: cursor);
    } finally {
      isLoadingOlderMessages = false;
      if (!_disposed) notifyListeners();
    }
    if (_disposed) return;

    result.fold((failure) => showError(failure.message), (page) {
      _olderMessagesCursor = page.nextCursor;
      _hasMoreOlderMessages = page.hasMore;
      _hasLoadedOlderMessages = true;
      _messageStore.merge(
        incoming: page.messages.map(_messageStore.toChatMessage),
      );
      notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scroll.hasClients || _disposed) return;
        final double addedExtent =
            scroll.position.maxScrollExtent - oldMaxExtent;
        scroll.jumpTo(
          (oldPixels + addedExtent)
              .clamp(
                scroll.position.minScrollExtent,
                scroll.position.maxScrollExtent,
              )
              .toDouble(),
        );
      });
    });
  }

  Future<void> _markConversationAsRead(int conversationId) async {
    final result = await _repo.markAsRead(conversationId);
    if (_disposed) return;
    result.fold((failure) => showError(failure.message), (_) {});
  }

  Future<void> _loadRealtimeConfig(int conversationId) async {
    final result = await _repo.getRealtimeConfig();
    if (_disposed || conversationId != _conversationId) return;
    result.fold(
      (failure) {
        if (!_hasReportedRealtimeConfigFailure) showError(failure.message);
        _hasReportedRealtimeConfigFailure = true;
      },
      (SupportChatRealtimeConfig config) {
        _hasReportedRealtimeConfigFailure = false;
        if (config.enabled) {
          _realtimeService.connect(conversationId, config: config);
        }
      },
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (_conversationId == null || !_isForeground || isConversationClosed) {
      return;
    }
    unawaited(_syncMessages());
    final Duration interval = _realtimeConnected
        ? _realtimeFallbackInterval
        : _pollInterval;
    _pollTimer = Timer.periodic(interval, (_) => _syncMessages());
  }

  void _onRealtimeConnectionChanged(bool connected) {
    if (_disposed) return;
    _realtimeConnected = connected;
    if (!connected) _onTypingChanged(null, false);
    if (!isConversationClosed) _startPolling();
  }

  Future<void> _syncMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null || isLoading || isConversationClosed) return;
    if (isRefreshing) {
      _hasQueuedRealtimeSync = true;
      return;
    }
    if (_isSyncing) return;
    if (!messagesLoaded) {
      await _loadInitialMessages();
      return;
    }

    _isSyncing = true;
    Either<Failure, SupportChatSyncModel> result;
    try {
      result = await _repo.syncMessages(
        conversationId: conversationId,
        changedAfter: _lastSyncedAt,
      );
    } finally {
      _isSyncing = false;
    }
    final bool shouldSyncAgain = _hasQueuedRealtimeSync;
    _hasQueuedRealtimeSync = false;
    if (_disposed) return;

    result.fold(
      (failure) {
        if (!_hasReportedSyncFailure) showError(failure.message);
        _hasReportedSyncFailure = true;
      },
      (sync) {
        _hasReportedSyncFailure = false;
        _lastSyncedAt = sync.syncedAt.subtract(const Duration(seconds: 1));
        if (sync.conversationIsClosed == true) _closeConversation();
        if (sync.messages.isEmpty && sync.deletedMessageIds.isEmpty) return;

        final bool shouldFollowLatest =
            scroll.hasClients &&
            scroll.position.maxScrollExtent - scroll.position.pixels <= 80;
        _messageStore.merge(
          incoming: sync.messages.map(_messageStore.toChatMessage),
          deletedIds: sync.deletedMessageIds,
        );
        notifyListeners();
        if (sync.messages.any((message) => !message.isMine)) {
          _markConversationAsRead(conversationId);
        }
        if (shouldFollowLatest) scrollToLatest();
      },
    );
    if (shouldSyncAgain) unawaited(_syncMessages());
  }

  void _handleRealtimeChatChange() {
    if (_isSyncing || isRefreshing) {
      _hasQueuedRealtimeSync = true;
      return;
    }
    unawaited(_syncMessages());
  }

  void _onConversationClosed(bool closed) {
    if (closed) _closeConversation();
  }

  void _closeConversation() {
    if (_disposed || isConversationClosed) return;
    isConversationClosed = true;
    typingActorType = null;
    _pollTimer?.cancel();
    _typingIndicatorTimer?.cancel();
    _realtimeService.disconnect();
    notifyListeners();
  }

  void _onTypingChanged(String? actorType, bool isTyping) {
    if (_disposed) return;
    if (actorType == 'user') {
      if (typingActorType != null) {
        _typingIndicatorTimer?.cancel();
        typingActorType = null;
        notifyListeners();
      }
      return;
    }
    _typingIndicatorTimer?.cancel();
    final String? nextActor = isTyping ? actorType : null;
    if (typingActorType != nextActor) {
      typingActorType = nextActor;
      notifyListeners();
    }
    if (isTyping) {
      _typingIndicatorTimer = Timer(const Duration(seconds: 4), () {
        if (!_disposed && typingActorType != null) {
          typingActorType = null;
          notifyListeners();
        }
      });
    }
  }

  void addPhotos(Iterable<String> paths) {
    photos.addAll(paths.take(maxPhotos - photos.length));
    notifyListeners();
  }

  void removePhoto(int index) {
    photos.removeAt(index);
    notifyListeners();
  }

  Future<void> send() async {
    final String text = input.text.trim();
    final List<String> sentPhotos = List<String>.of(photos);
    final int? conversationId = _conversationId;
    if ((text.isEmpty && sentPhotos.isEmpty) ||
        conversationId == null ||
        isSending ||
        isConversationClosed) {
      return;
    }

    isSending = true;
    input.clear();
    photos.clear();
    notifyListeners();
    bool messageSent = false;
    try {
      final String clientMessageId = _sendIdempotencyKey.forRequest(
        <String>[text, ...sentPhotos].join('\n'),
      );
      final result = await _repo.sendMessage(
        conversationId: conversationId,
        body: text,
        imagePaths: sentPhotos,
        clientMessageId: clientMessageId,
      );
      if (_disposed) return;

      result.fold((failure) => showError(failure.message), (message) {
        messageSent = true;
        _sendIdempotencyKey.markConsumed();
        _messageStore.merge(
          incoming: <ChatMessage>[_messageStore.toChatMessage(message)],
        );
        notifyListeners();
        scrollToLatest();
      });
    } finally {
      if (!_disposed) {
        if (!messageSent && input.text.isEmpty) {
          input.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
        if (!messageSent && photos.isEmpty) photos.addAll(sentPhotos);
        isSending = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadInitialMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null) return;

    if (messages.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    Either<Failure, SupportChatMessagesPage> result;
    try {
      result = await _repo.getMessages(conversationId);
    } finally {
      if (!_disposed) {
        isLoading = false;
        initialScrollPositioned = true;
        notifyListeners();
      }
    }
    if (_disposed) return;

    result.fold((failure) => showError(failure.message), (page) {
      _olderMessagesCursor = page.nextCursor;
      _hasMoreOlderMessages = page.hasMore;
      _messageStore.merge(
        incoming: page.messages.reversed.map(_messageStore.toChatMessage),
        replace: true,
      );
      messagesLoaded = true;
      isLoading = false;
      initialScrollPositioned = false;
      notifyListeners();
      scrollToLatest(
        animate: false,
        onPositioned: () {
          if (_disposed) return;
          initialScrollPositioned = true;
          notifyListeners();
        },
      );
      _markConversationAsRead(conversationId);
    });
  }

  void scrollToLatest({bool animate = true, VoidCallback? onPositioned}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients || !scroll.position.hasContentDimensions) return;
      final double latestOffset = scroll.position.maxScrollExtent;
      if (!animate) {
        scroll.jumpTo(latestOffset);
        onPositioned?.call();
        return;
      }
      scroll
          .animateTo(
            latestOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          )
          .whenComplete(() => onPositioned?.call());
    });
  }
}
