import 'package:flutter/material.dart';

/// Wraps [child] and, while [isLoading] is true, covers it with a translucent
/// barrier holding a centered progress indicator.
///
/// Use it for in-place actions that must not be interrupted (e.g. changing the
/// default address): the content stays visible underneath but cannot be tapped,
/// so no second request can be fired while the first one is in flight.
class BlockingLoadingOverlay extends StatelessWidget {
  const BlockingLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;

  /// When true the barrier and the progress indicator are shown and every
  /// pointer event on [child] is swallowed.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // AbsorbPointer keeps the events from reaching the content instead of
        // letting them fall through to whatever sits behind the overlay.
        AbsorbPointer(absorbing: isLoading, child: child),
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: colors.onPrimary.withValues(alpha: 0.6),
              child: Center(
                child: CircularProgressIndicator(color: colors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
