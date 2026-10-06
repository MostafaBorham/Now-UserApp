import 'package:flutter/material.dart';

/// Keeps the whole app above the system navigation bar.
///
/// Android 15+ draws apps under the navigation bar (edge-to-edge is enforced
/// from target SDK 35), and this app was never laid out for that: the bottom
/// buttons of sheets and screens sat under the 3-button bar (BUG-001, QA V2).
/// Wrapping the app once, above the navigator, covers every screen, sheet,
/// dialog and toast; widgets inside see no bottom inset, so ones that already
/// pad for it don't pad twice. The bar's strip shows the scaffold colour, as
/// it did before Android 15.
class AboveSystemNavBar extends StatelessWidget {
  const AboveSystemNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(top: false, left: false, right: false, child: child),
    );
  }
}
