import 'package:flutter/material.dart';

/// Palette for colors introduced by the Payment Methods screen.
///
/// Names describe what each color is *for* (semantic) rather than its hue,
/// so screens read clearly and future theming can remap them in one place.
class AppColors {
  AppColors._();

  /// Dark text for section headers ("Saved Cards", "Add New Card"...).
  static const Color sectionTitle = Color(0xFF262626);

  /// Near-black text for card / payment-method names.
  static const Color optionTitle = Color(0xFF1A1A1A);

  /// Value text inside the "Add New Card" form (name, number, dates).
  static const Color fieldValue = Color(0xFF262626);

  /// Muted grey for the "Default" label, field labels and hints.
  static const Color mutedLabel = Color(0xFFA1A1A1);

  /// Light grey fill behind saved-card tiles, method tiles and the form.
  static const Color tileBackground = Color(0xFFF7F7F7);

  /// Hairline colour for dividers inside the form and above the CTAs.
  static const Color divider = Color(0xFFEDEDED);

  /// Brand green for the selected radio indicator and the "Continue" button.
  static const Color selectedIndicator = Color(0xFF4BB749);

  /// Outline of an unselected radio indicator.
  static const Color unselectedIndicator = Color(0xFFD3D3D3);

  /// Border of the outlined "Add New Card" button.
  static const Color outlinedButtonBorder = Color(0xFFE5E5E5);

  /// Filled input background on the personal-information form.
  static const Color fieldFill = Color(0xFFF1F1F1);

  /// Light-green background of the "Paste Code" pill.
  static const Color pasteCodeBackground = Color(0xFFE7F6E8);
}
