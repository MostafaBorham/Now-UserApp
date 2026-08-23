import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';

/// The search bar that pins to the top of [HomeView] once the in-header search
/// field scrolls up to the top of the page.
///
/// It is placed so the field lands at the exact resting position the in-flow
/// header field reaches at the pin moment (right under the status bar, same
/// horizontal inset) — so pinning reads as the same field stopping, never as a
/// second field popping in. The primary background is a curtain that drops down
/// *behind* the fixed field, its reveal driven by [progress] (0 → 1).
class HomePinnedSearchBar extends StatelessWidget {
  const HomePinnedSearchBar({super.key, required this.progress, this.onTap});

  /// Curtain reveal, 0 (hidden, field only) → 1 (fully dropped background).
  final double progress;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double t = progress.clamp(0.0, 1.0);
    return Stack(
      children: <Widget>[

        Positioned.fill(
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t,
              child: ColoredBox(
                color: colors.primary500Main,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PrimarySearchField(onTap: onTap),
          ),
        ),
      ],
    );
  }
}
