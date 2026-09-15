import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_card.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_type.dart';













class AppToast {
  const AppToast._();

  static const Duration _visibleDuration = Duration(seconds: 4);





  static const Duration _routeChangeGrace = Duration(milliseconds: 500);

  static OverlayEntry? _entry;
  static DateTime? _shownAt;


  static void showError(BuildContext context, String message, {String? title}) {
    _show(
      context,
      type: AppToastType.error,
      title: title ?? LangKeys.errorTitleKey.tr(),
      message: message.tr(),
    );
  }


  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _show(
      context,
      type: AppToastType.success,
      title: title ?? LangKeys.successTitleKey.tr(),
      message: message.tr(),
    );
  }

  static void _show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    required String message,
  }) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _removeCurrent();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppToastOverlay(
        type: type,
        title: title,
        message: message,
        duration: _visibleDuration,
        onDismissed: () {
          if (_entry == entry) {
            _entry = null;
            _shownAt = null;
          }
          if (entry.mounted) entry.remove();
        },
      ),
    );

    _entry = entry;
    _shownAt = DateTime.now();
    overlay.insert(entry);
  }





  static void dismissForRouteChange() {
    if (_entry == null) return;
    final DateTime? shownAt = _shownAt;
    if (shownAt != null &&
        DateTime.now().difference(shownAt) < _routeChangeGrace) {
      return;
    }
    _removeCurrent();
  }

  static void _removeCurrent() {
    final OverlayEntry? entry = _entry;
    _entry = null;
    _shownAt = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}



class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final AppToastType type;
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    if (mounted) await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (DragEndDetails details) {
                if ((details.primaryVelocity ?? 0) < 0) _dismiss();
              },
              child: AppToastCard(
                type: widget.type,
                title: widget.title,
                message: widget.message,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
