import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

import 'settings_tile.dart';

/// A titled group of setting rows (e.g. "General", "Support").
///
/// Renders a section title followed by a rounded card that holds the [items].
/// Reused for every group on the profile screen. A [isDanger] section (log
/// out, delete account) sits on a light red card with every row in red.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    this.title,
    required this.items,
    this.isDanger = false,
  });

  /// Optional header above the card. Omitted (e.g. the guest view) renders
  /// the card on its own with no title.
  final String? title;
  final List<SettingsItem> items;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.tertiaryContainer,
              ),
            ),
          ),
        Material(
          color: isDanger
              ? colors.red300Main.withValues(alpha: 0.1)
              : colors.onTertiaryContainer,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final item in items)
                  SettingsTile(
                    item: item,
                    color: isDanger ? colors.red400 : null,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
