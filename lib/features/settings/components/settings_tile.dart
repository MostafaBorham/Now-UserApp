import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Data model describing a single tappable row inside a [SettingsSection].
class SettingsItem {
  const SettingsItem({
    required this.iconAsset,
    required this.label,
    this.onTap,
  });

  /// Path to the SVG icon (from the `assets/svg` folder).
  final String iconAsset;

  /// Text shown next to the icon.
  final String label;

  /// Called when the row is tapped.
  final VoidCallback? onTap;
}

/// A single settings row: leading icon, label, and a trailing chevron.
///
/// Icons are rendered straight from the provided SVG assets, so they are
/// used as-is (placeholders) and never redrawn in code.
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.item});

  final SettingsItem item;

  static const double _iconSize = 22;
  static const double _iconSlot = 24;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: _iconSlot,
              height: _iconSlot,
              child: Center(
                child: SvgPicture.asset(
                  item.iconAsset,
                  width: _iconSize,
                  height: _iconSize,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.tertiaryContainer,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: context.colors.neutral500,
            ),
          ],
        ),
      ),
    );
  }
}
