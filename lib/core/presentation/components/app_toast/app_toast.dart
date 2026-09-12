import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_card.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_type.dart';

/// App-wide toast, shown as a top overlay above every other layer — including
/// modal bottom sheets and dialogs, which a [SnackBar] renders *behind*. This
/// replaces the former `ErrorSnackBar` / `SuccessSnackBar`.
///
/// It inserts into the root [Overlay], so a single call from anywhere floats an
/// [AppToastCard] down from the top, auto-dismisses after a few seconds, and can
/// be tapped or swiped up to dismiss early. Only one toast is on screen at a
/// time — a new one replaces the current.
///
/// [message] may be a [LangKeys] key or a raw server message; it is passed
/// through `.tr()`, which leaves non-key strings untouched. [title] defaults to a
/// localized severity label.
class AppToast {
  const AppToast._();

  static const Duration _visibleDuration = Duration(seconds: 4);

  /// A toast shown within this window of a navigation is kept, not dismissed by
  /// it — that is the deliberate "show a message, then leave" pattern, where the
  /// toast is meant to be read on the destination. Genuine user navigation
  /// happens well after this.
  static const Duration _routeChangeGrace = Duration(milliseconds: 500);

  static OverlayEntry? _entry;
  static DateTime? _shownAt;

  /// Shows an error toast (red accent, alert icon).
  static void showError(BuildContext context, String message, {String? title}) {
    _show(
      context,
      type: AppToastType.error,
      title: title ?? LangKeys.errorTitleKey.tr(),
      message: message.tr(),
    );
  }

  /// Shows a success toast (green accent, check icon).
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

  /// Dismisses the visible toast when the user leaves the page it belongs to.
  /// Called by [AppToastRouteObserver] on every navigation. A toast shown in the
  /// same beat as the navigation (within [_routeChangeGrace]) is left alone, so
  /// deliberate "show a message, then navigate" flows still reach the next page.
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

/// Hosts one toast: slides + fades it in from the top, holds for [duration],
/// then animates out. Dismisses early on tap or an upward swipe.
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
