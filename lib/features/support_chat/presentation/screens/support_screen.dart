import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/components/image_source_sheet.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/support_chat/presentation/controllers/support_chat_controller.dart';
import 'package:nowdelivery_user_app/features/support_chat/presentation/widgets/support_chat_view.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key, this.orderUuid});

  final String? orderUuid;

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with WidgetsBindingObserver {
  late final SupportChatController _controller;
  final ImagePicker _picker = ImagePicker();
  Timer? _keyboardCloseScrollTimer;
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = SupportChatController(
      orderUuid: widget.orderUuid,
      localeCode: () => context.locale.languageCode,
      showError: (message) {
        if (mounted) AppToast.showError(context, message);
      },
    );
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
          _controller.onResumed();
        } else {
          _controller.onPaused();
          _keyboardCloseScrollTimer?.cancel();
        }
      },
    );
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _keyboardCloseScrollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_controller.scroll.hasClients ||
          !_controller.scroll.position.hasContentDimensions) {
        return;
      }
      _keyboardCloseScrollTimer?.cancel();
      final Duration delay = MediaQuery.viewInsetsOf(context).bottom > 0
          ? const Duration(milliseconds: 100)
          : const Duration(milliseconds: 120);
      _keyboardCloseScrollTimer = Timer(
        delay,
        () => _controller.scrollToLatest(),
      );
    });
  }

  Future<void> _pickPhotos() async {
    final int remaining =
        SupportChatController.maxPhotos - _controller.photos.length;
    if (remaining <= 0) return;
    final ImageSource? source = await showImageSourceSheet(context);
    if (source == null || !mounted) return;

    try {
      // Resized on the device, as the complaint photos are.
      final List<XFile> picked = source == ImageSource.camera
          ? <XFile>[
              ?await _picker.pickImage(
                source: source,
                imageQuality: 85,
                maxWidth: 1600,
                maxHeight: 1600,
              ),
            ]
          : await _picker.pickMultiImage(
              imageQuality: 85,
              maxWidth: 1600,
              maxHeight: 1600,
              // The picker rejects a limit below 2; addPhotos caps it anyway.
              limit: remaining < 2 ? null : remaining,
            );
      _controller.addPhotos(picked.map((XFile photo) => photo.path));
    } catch (_) {
      // E.g. photo access denied — say so rather than doing nothing.
      if (mounted) AppToast.showError(context, LangKeys.imagePickingErrorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userAvatarUrl = ref
        .watch(getProfileProvider)
        .valueOrNull
        ?.avatarUrl;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => SupportChatView(
        title:
            (widget.orderUuid == null
                    ? LangKeys.support
                    : LangKeys.driverChatTitleKey)
                .tr(),
        onClose: context.canPop() ? context.pop : null,
        messages: _controller.messages,
        scrollController: _controller.scroll,
        onRefresh: _controller.refreshMessages,
        initialScrollPositioned: _controller.initialScrollPositioned,
        isLoadingOlderMessages: _controller.isLoadingOlderMessages,
        typingActorType: _controller.typingActorType,
        isConversationClosed: _controller.isConversationClosed,
        inputController: _controller.input,
        isSending: _controller.isSending,
        onSend: _controller.send,
        onAttach: _pickPhotos,
        photos: _controller.photos,
        onRemovePhoto: _controller.removePhoto,
        userAvatarUrl: userAvatarUrl,
      ),
    );
  }
}
