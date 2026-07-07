import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'settings_tile.dart';

/// A titled group of setting rows (e.g. "General", "Support").
///
/// Renders a bold section title followed by a rounded grey card that holds
/// the [items]. Reused for every group on the profile screen.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Material(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final item in items) SettingsTile(item: item),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
