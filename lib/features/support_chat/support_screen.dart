import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
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

class _SupportScreenState extends ConsumerState<SupportScreen> {
  static const Duration _pollInterval = Duration(seconds: 15);
  static const Duration _realtimeFallbackInterval = Duration(seconds: 60);

  final List<ChatMessage> _messages = [];
  final SupportChatRepo _repo = SupportChatRepo();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final SupportChatRealtimeService _realtimeService;

  Timer? _pollTimer;
  AppLifecycleListener? _lifecycleListener;
  int? _conversationId;
  DateTime _lastSyncedAt = DateTime.now().toUtc().subtract(
    const Duration(seconds: 1),
  );
  bool _isLoading = true;
  bool _messagesLoaded = false;
  bool _isSending = false;
  bool _isSyncing = false;
  bool _hasReportedSyncFailure = false;
  bool _showWelcomeMessage = false;
  bool _realtimeConnected = false;
  bool _isForeground = true;
  bool _hasReportedRealtimeConfigFailure = false;
  bool _hasQueuedRealtimeSync = false;

  @override
  void initState() {
    super.initState();
    _realtimeService = SupportChatRealtimeService(
      onChatChanged: _handleRealtimeChatChange,
      onConnectionChanged: _onRealtimeConnectionChanged,
    );
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
          _realtimeService.disconnect();
        }
      },
    );
    _openSupportConversation();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _lifecycleListener?.dispose();
    _realtimeService.disconnect();
    _repo.cancelRequests();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openSupportConversation() async {
    final conversationResult = await _repo.openConversation();
    if (!mounted) return;

    final int? conversationId = conversationResult.fold((failure) {
      _showError(failure.message);
      return null;
    }, (id) => id);
    if (conversationId == null) {
      setState(() => _isLoading = false);
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
        setState(() => _isLoading = false);
      },
      (messages) {
        final List<SupportChatMessageModel> chronological = messages.reversed
            .toList();
        if (chronological.isEmpty) _showWelcomeMessage = true;
        setState(() {
          _messages
            ..clear()
            ..addAll(<ChatMessage>[
              if (_showWelcomeMessage) _welcomeMessage(),
              ...chronological.map(_toChatMessage),
            ]);
          _messagesLoaded = true;
          _isLoading = false;
        });
        _markConversationAsRead(conversationId);
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
    _startPolling();
  }

  Future<void> _syncMessages() async {
    final int? conversationId = _conversationId;
    if (conversationId == null || _isSyncing || _isLoading) return;
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
            ..addAll(<ChatMessage>[
              if (_showWelcomeMessage) _welcomeMessage(),
              ...chronological,
            ]);
        });
        if (sync.messages.any((message) => !message.isMine)) {
          _markConversationAsRead(conversationId);
        }
        _scrollToLatest();
      },
    );
    if (shouldSyncAgain) unawaited(_syncMessages());
  }

  void _handleRealtimeChatChange() {
    if (_isSyncing) {
      _hasQueuedRealtimeSync = true;
      return;
    }
    unawaited(_syncMessages());
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

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
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
              child: _isLoading && _messages.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colors.primary500Main,
                      ),
                    )
                  : ListView.separated(
                      controller: _scroll,
                      itemCount: _messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 18),
                      itemBuilder: (context, index) => ChatBubble(
                        message: _messages[index],
                        userAvatarUrl: userAvatarUrl,
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
