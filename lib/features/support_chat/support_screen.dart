import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

import 'components/chat_bubble.dart';
import 'components/message_input_bar.dart';
import 'data/datasources/remote/api/support_chat_realtime_service.dart';
import 'data/models/support_chat_message_model.dart';
import 'data/models/support_chat_realtime_config.dart';
import 'data/repo/support_chat_repo.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with WidgetsBindingObserver {
  static const Duration _pollInterval = Duration(seconds: 15);
  static const Duration _realtimeFallbackInterval = Duration(seconds: 60);

  final List<ChatMessage> _messages = [];
  final SupportChatRepo _repo = SupportChatRepo();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final SupportChatRealtimeService _realtimeService;

  Timer? _pollTimer;
  Timer? _typingIndicatorTimer;
  Timer? _keyboardCloseScrollTimer;
  AppLifecycleListener? _lifecycleListener;
  int? _conversationId;
  DateTime _lastSyncedAt = DateTime.now().toUtc().subtract(
    const Duration(seconds: 1),
  );
  bool _isLoading = true;
  bool _messagesLoaded = false;
  bool _isSending = false;
  bool _isSyncing = false;
  bool _isRefreshing = false;
  bool _hasReportedSyncFailure = false;
  bool _realtimeConnected = false;
  bool _isForeground = true;
  bool _hasReportedRealtimeConfigFailure = false;
  bool _hasQueuedRealtimeSync = false;
  bool _supportIsTyping = false;
  bool _initialScrollPositioned = false;
  bool _hasMoreOlderMessages = false;
  bool _isLoadingOlderMessages = false;
  bool _hasLoadedOlderMessages = false;
  String? _olderMessagesCursor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _realtimeService = SupportChatRealtimeService(
      onChatChanged: _handleRealtimeChatChange,
      onTypingChanged: _onSupportTypingChanged,
      onConnectionChanged: _onRealtimeConnectionChanged,
    );
    _scroll.addListener(_handleScroll);
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
          _isForeground = true;
          final int? conversationId = _conversationId;
          if (conversationId != null) _loadRealtimeConfig(conversationId);
          _startPolling();
        } else {
          _isForeground = false;
          _pollTimer?.cancel();
          _typingIndicatorTimer?.cancel();
          _keyboardCloseScrollTimer?.cancel();
          _realtimeService.disconnect();
        }
      },
    );
    _openSupportConversation();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _keyboardCloseScrollTimer?.cancel();
    _scroll.removeListener(_handleScroll);
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener?.dispose();
    _realtimeService.disconnect();
    _repo.cancelRequests();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) {
        return;
      }
      if (MediaQuery.viewInsetsOf(context).bottom > 0) {
        _keyboardCloseScrollTimer?.cancel();
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
        return;
      }

      _keyboardCloseScrollTimer?.cancel();
      _keyboardCloseScrollTimer = Timer(const Duration(milliseconds: 120), () {
        if (mounted) _scrollToLatest();
      });
    });
  }

  Future<void> _openSupportConversation() async {
    final conversationResult = await _repo.openConversation();
    if (!mounted) return;

    final int? conversationId = conversationResult.fold((failure) {
      _showError(failure.message);
      return null;
    }, (id) => id);
    if (conversationId == null) {
      setState(() {
        _isLoading = false;
        _initialScrollPositioned = true;
      });
      return;
    }

    setState(() => _conversationId = conversationId);
    await _loadInitialMessages();
    if (mounted) {
      _loadRealtimeConfig(conversationId);
      _startPolling();
    }
  }

  Future<void> _loadRealtimeConfig(int conversationId) async {
    final result = await _repo.getRealtimeConfig();
    if (!mounted || conversationId != _conversationId) return;
    result.fold(
      (failure) {
        if (!_hasReportedRealtimeConfigFailure) {
          _showError(failure.message);
        }
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

  Future<void> _loadInitialMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null) return;

    if (mounted && _messages.isEmpty) {
      setState(() => _isLoading = true);
    }

    final result = await _repo.getMessages(conversationId);
    if (!mounted) return;

    result.fold(
      (failure) {
        _showError(failure.message);
        setState(() {
          _isLoading = false;
          _initialScrollPositioned = true;
        });
      },
      (page) {
        final List<SupportChatMessageModel> chronological = page
            .messages
            .reversed
            .toList();
        _olderMessagesCursor = page.nextCursor;
        _hasMoreOlderMessages = page.hasMore;
        setState(() {
          _messages
            ..clear()
            ..addAll(<ChatMessage>[
              _welcomeMessage(),
              ...chronological.map(_toChatMessage),
            ]);
          _messagesLoaded = true;
          _isLoading = false;
        });
        _scrollToLatest(
          animate: false,
          onPositioned: () {
            if (mounted) setState(() => _initialScrollPositioned = true);
          },
        );
        _markConversationAsRead(conversationId);
      },
    );
  }

  Future<void> _refreshMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null || _isLoading || _isRefreshing) return;

    _isRefreshing = true;
    final result = await _repo.getMessages(conversationId);
    _isRefreshing = false;
    final bool shouldSyncAgain = _hasQueuedRealtimeSync;
    _hasQueuedRealtimeSync = false;
    if (!mounted) return;

    result.fold((failure) => _showError(failure.message), (page) {
      final Map<int, ChatMessage> merged = {
        for (final ChatMessage message in _messages)
          if (message.id != null) message.id!: message,
        for (final SupportChatMessageModel message in page.messages)
          message.id: _toChatMessage(message),
      };
      final List<ChatMessage> chronological = merged.values.toList()
        ..sort((a, b) => a.id!.compareTo(b.id!));
      if (!_hasLoadedOlderMessages) {
        _olderMessagesCursor = page.nextCursor;
        _hasMoreOlderMessages = page.hasMore;
      }
      setState(() {
        _messages
          ..clear()
          ..addAll(<ChatMessage>[_welcomeMessage(), ...chronological]);
        _messagesLoaded = true;
      });
      _markConversationAsRead(conversationId);
    });
    if (shouldSyncAgain) unawaited(_syncMessages());
  }

  void _handleScroll() {
    if (_scroll.hasClients &&
        _initialScrollPositioned &&
        _scroll.position.pixels <= 80 &&
        _hasMoreOlderMessages &&
        !_isLoadingOlderMessages &&
        !_isRefreshing &&
        !_isLoading) {
      unawaited(_loadOlderMessages());
    }
  }

  Future<void> _loadOlderMessages() async {
    final int? conversationId = _conversationId;
    final String? cursor = _olderMessagesCursor;
    if (conversationId == null ||
        cursor == null ||
        !_hasMoreOlderMessages ||
        _isLoadingOlderMessages) {
      return;
    }

    setState(() => _isLoadingOlderMessages = true);
    final double oldPixels = _scroll.hasClients ? _scroll.position.pixels : 0;
    final double oldMaxExtent = _scroll.hasClients
        ? _scroll.position.maxScrollExtent
        : 0;
    final result = await _repo.getMessages(conversationId, cursor: cursor);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoadingOlderMessages = false);
        _showError(failure.message);
      },
      (page) {
        final List<ChatMessage> older = page.messages.reversed
            .map(_toChatMessage)
            .toList();
        final Map<int, ChatMessage> merged = {
          for (final ChatMessage message in _messages)
            if (message.id != null) message.id!: message,
          for (final ChatMessage message in older)
            if (message.id != null) message.id!: message,
        };
        final List<ChatMessage> chronological = merged.values.toList()
          ..sort((a, b) => a.id!.compareTo(b.id!));
        _olderMessagesCursor = page.nextCursor;
        _hasMoreOlderMessages = page.hasMore;
        _hasLoadedOlderMessages = true;
        setState(() {
          _messages
            ..clear()
            ..addAll(<ChatMessage>[_welcomeMessage(), ...chronological]);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scroll.hasClients) {
            if (mounted) setState(() => _isLoadingOlderMessages = false);
            return;
          }
          final double addedExtent =
              _scroll.position.maxScrollExtent - oldMaxExtent;
          _scroll.jumpTo(
            (oldPixels + addedExtent)
                .clamp(
                  _scroll.position.minScrollExtent,
                  _scroll.position.maxScrollExtent,
                )
                .toDouble(),
          );
          if (mounted) setState(() => _isLoadingOlderMessages = false);
        });
      },
    );
  }

  Future<void> _markConversationAsRead(int conversationId) async {
    final result = await _repo.markAsRead(conversationId);
    if (!mounted) return;
    result.fold((failure) => _showError(failure.message), (_) {});
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (_conversationId == null || !_isForeground) return;
    _syncMessages();
    final Duration interval = _realtimeConnected
        ? _realtimeFallbackInterval
        : _pollInterval;
    _pollTimer = Timer.periodic(interval, (_) => _syncMessages());
  }

  void _onRealtimeConnectionChanged(bool connected) {
    if (!mounted) return;
    _realtimeConnected = connected;
    if (!connected) _onSupportTypingChanged(false);
    _startPolling();
  }

  Future<void> _syncMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null || _isLoading) return;
    if (_isRefreshing) {
      _hasQueuedRealtimeSync = true;
      return;
    }
    if (_isSyncing) return;
    if (!_messagesLoaded) {
      await _loadInitialMessages();
      return;
    }

    _isSyncing = true;
    final result = await _repo.syncMessages(
      conversationId: conversationId,
      changedAfter: _lastSyncedAt,
    );
    _isSyncing = false;
    final bool shouldSyncAgain = _hasQueuedRealtimeSync;
    _hasQueuedRealtimeSync = false;
    if (!mounted) return;

    result.fold(
      (failure) {
        if (!_hasReportedSyncFailure) _showError(failure.message);
        _hasReportedSyncFailure = true;
      },
      (sync) {
        _hasReportedSyncFailure = false;
        _lastSyncedAt = sync.syncedAt.subtract(const Duration(seconds: 1));
        if (sync.messages.isEmpty && sync.deletedMessageIds.isEmpty) return;

        final bool shouldFollowLatest =
            _scroll.hasClients &&
            _scroll.position.maxScrollExtent - _scroll.position.pixels <= 80;
        final Map<int, ChatMessage> updatedMessages = {
          for (final ChatMessage message in _messages)
            if (message.id != null) message.id!: message,
        };
        for (final int id in sync.deletedMessageIds) {
          updatedMessages.remove(id);
        }
        for (final SupportChatMessageModel message in sync.messages) {
          updatedMessages[message.id] = _toChatMessage(message);
        }
        final List<ChatMessage> chronological = updatedMessages.values.toList()
          ..sort((a, b) => a.id!.compareTo(b.id!));
        setState(() {
          _messages
            ..clear()
            ..addAll(<ChatMessage>[_welcomeMessage(), ...chronological]);
        });
        if (sync.messages.any((message) => !message.isMine)) {
          _markConversationAsRead(conversationId);
        }
        if (shouldFollowLatest) _scrollToLatest();
      },
    );
    if (shouldSyncAgain) unawaited(_syncMessages());
  }

  void _handleRealtimeChatChange() {
    if (_isSyncing || _isRefreshing) {
      _hasQueuedRealtimeSync = true;
      return;
    }
    unawaited(_syncMessages());
  }

  void _onSupportTypingChanged(bool isTyping) {
    _typingIndicatorTimer?.cancel();
    if (!mounted) return;
    if (_supportIsTyping != isTyping) {
      setState(() => _supportIsTyping = isTyping);
    }
    if (isTyping) {
      _typingIndicatorTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _supportIsTyping) {
          setState(() => _supportIsTyping = false);
        }
      });
    }
  }

  ChatMessage _toChatMessage(SupportChatMessageModel message) => ChatMessage(
    id: message.id,
    text: message.body,
    time: message.createdAt == null
        ? ''
        : DateFormat.Hm(
            context.locale.languageCode,
          ).format(message.createdAt!.toLocal()),
    createdAt: message.createdAt,
    fromAgent: !message.isMine,
  );

  String _supportWelcomeMessage() {
    final String translated = LangKeys.supportWelcomeMessageKey.tr();
    if (translated != LangKeys.supportWelcomeMessageKey) return translated;

    return context.locale.languageCode == 'ar'
        ? 'مرحبًا بك في خدمة عملاء ناو، كيف يمكننا مساعدتك؟'
        : 'Welcome to Now Customer Service. How can we help you?';
  }

  ChatMessage _welcomeMessage() =>
      ChatMessage(text: _supportWelcomeMessage(), time: '', fromAgent: true);

  Future<void> _send() async {
    final String text = _input.text.trim();
    final int? conversationId = _conversationId;
    if (text.isEmpty || conversationId == null || _isSending) return;

    setState(() => _isSending = true);
    final result = await _repo.sendMessage(
      conversationId: conversationId,
      body: text,
    );
    if (!mounted) return;

    result.fold((failure) => _showError(failure.message), (message) {
      setState(() {
        _messages.add(_toChatMessage(message));
        _input.clear();
      });
      _scrollToLatest();
    });
    if (mounted) setState(() => _isSending = false);
  }

  void _scrollToLatest({bool animate = true, VoidCallback? onPositioned}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) {
        return;
      }
      final double latestOffset = _scroll.position.maxScrollExtent;
      if (!animate) {
        _scroll.jumpTo(latestOffset);
        onPositioned?.call();
        return;
      }
      _scroll
          .animateTo(
            latestOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          )
          .whenComplete(() => onPositioned?.call());
    });
  }

  void _showError(String message) {
    if (mounted) AppToast.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Size screenSize = MediaQuery.sizeOf(context);
    final String? userAvatarUrl = ref
        .watch(getProfileProvider)
        .valueOrNull
        ?.avatarUrl;
    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.support.tr(),
        leading: context.canPop()
            ? InkWell(
                onTap: () => context.pop(),
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
              )
            : const SizedBox.shrink(),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Opacity(
                    opacity: _initialScrollPositioned ? 1 : 0,
                    child: AppRefreshIndicator(
                      onRefresh: _refreshMessages,
                      child: ListView.separated(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.manual,
                        itemCount: _messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 18),
                        itemBuilder: (context, index) => ChatBubble(
                          message: _messages[index],
                          userAvatarUrl: userAvatarUrl,
                        ),
                      ),
                    ),
                  ),
                  if (!_initialScrollPositioned)
                    Center(
                      child: CircularProgressIndicator(
                        color: colors.primary500Main,
                      ),
                    ),
                  if (_isLoadingOlderMessages)
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
            if (_supportIsTyping)
              Container(
                margin: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    LangKeys.supportTypingIndicatorKey.tr(),
                    style: TextStyle(fontSize: 12, color: colors.neutral500),
                  ),
                ),
              ),
            MessageInputBar(
              controller: _input,
              onSend: _isSending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
