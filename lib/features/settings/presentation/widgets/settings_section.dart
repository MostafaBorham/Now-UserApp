import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

import 'settings_tile.dart';





class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    this.title,
    required this.items,
  });



  final String? title;
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.colors.tertiaryContainer,
              ),
            ),
          ),
        Material(
          color: context.colors.onTertiaryContainer,
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
