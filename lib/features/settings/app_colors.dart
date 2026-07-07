import 'package:flutter/material.dart';

/// Central color palette for the Profile / Settings screen.
///
/// Every new color introduced by this screen lives here so the whole
/// design can be re-themed from a single place.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand / surfaces
  // ---------------------------------------------------------------------------

  /// Golden "honey" yellow used for the header background.
  static const Color primaryYellow = Color(0xFFFFC529);

  /// Base screen background.
  static const Color background = Color(0xFFFFFFFF);

  /// Light grey fill used behind the grouped setting rows.
  static const Color cardBackground = Color(0xFFF7F7F7);

  // ---------------------------------------------------------------------------
  // Text & icons
  // ---------------------------------------------------------------------------

  /// Primary near-black used for titles, the name and row labels.
  static const Color textPrimary = Color(0xFF262626);

  /// Trailing chevron / disclosure indicator on each row.
  static const Color chevron = Color(0xFFA6A6A6);

  // ---------------------------------------------------------------------------
  // "Member since" date pill
  // ---------------------------------------------------------------------------

  static const Color datePillBackground = Color(0xFFE6F7EC);
  static const Color datePillText = Color(0xFF2FA84F);

  // ---------------------------------------------------------------------------
  // Avatar
  // ---------------------------------------------------------------------------

  /// Soft fallback color shown behind the circular avatar placeholder.
  static const Color avatarPlaceholder = Color(0xFFEDE7F1);

  // ---------------------------------------------------------------------------
  // Log out button
  // ---------------------------------------------------------------------------

  static const Color logoutRed = Color(0xFFD62A3A);
  static const Color logoutForeground = Color(0xFFFCFCFC);

  // ---------------------------------------------------------------------------
  // Personal information / edit form
  // ---------------------------------------------------------------------------

  /// Primary green used for the Edit / Save buttons and the selected gender.
  static const Color primaryGreen = Color(0xFF3EB75D);

  /// Primary green used for the Edit / Save buttons and the selected gender.
  static const Color grey = Color(0xFFF5F5F5);

  /// Foreground (text) color on filled buttons and the selected gender.
  static const Color buttonForeground = Color(0xFFFFFFFF);

  /// Muted grey used for field labels.
  static const Color fieldLabel = Color(0xFFA1A1A1);

  /// Lighter grey used for placeholder / hint text and form icons.
  static const Color hintText = Color(0xFFA1A1A1);

  /// Thin separator line between read-only fields.
  static const Color divider = Color(0xFFEAEAEA);

  /// Fill for editable input pills and the gender toggle track.
  static const Color inputFill = Color(0xFFF2F2F2);

  /// Semi-transparent overlay behind the avatar's camera icon (~40% black).
  static const Color avatarOverlay = Color(0x66000000);

  // ---------------------------------------------------------------------------
  // My Address screen
  // ---------------------------------------------------------------------------

  /// Soft green gradient filling the selected / default address card.
  /// Runs from a pale warm-white (top-left) to a light mint (bottom-right).
  static const Color selectedAddressStart = Color(0xFFFCFDF2);
  static const Color selectedAddressEnd = Color(0xFFD6EFDD);

  /// Hairline border framing the selected / default address card.
  static const Color selectedAddressBorder = Color(0xFFCDEBD4);

  /// Medium grey used for the address line beneath each card title.
  static const Color addressText = Color(0xFF4D4D4D);

  /// Hollow ring of an unselected address radio button.
  static const Color radioUnselected = Color(0xFFD1D1D1);

  // ---------------------------------------------------------------------------
  // Discount Code screen (coupon tickets)
  // ---------------------------------------------------------------------------

  /// Near-black green value panel used on the alternating (dark) coupon.
  static const Color couponDark = Color(0xFF16260F);

  /// Deep green used for the big "NN%" on amber coupons and the code chip.
  static const Color couponDeepGreen = Color(0xFF2B6B2A);

  /// Brighter green used for the "Discount Code" title on the body panel.
  static const Color couponTitleGreen = Color(0xFF34A13B);

  /// Body (right) panel behind an amber coupon.
  static const Color couponMint = Color(0xFFE7F4EB);

  /// Body (right) panel behind a dark coupon.
  static const Color couponCream = Color(0xFFFBF6DF);

  /// Grey used for the validity and minimum-purchase lines.
  static const Color couponMeta = Color(0xFF9E9E9E);

  /// Fill of the copyable code chip.
  static const Color couponChipBg = Color(0xFFD6F5E1);

  // ---------------------------------------------------------------------------
  // FAQ screen
  // ---------------------------------------------------------------------------

  /// Softly tinted background of an expanded FAQ card (collapsed cards use
  /// [cardBackground]).
  static const Color faqExpandedBg = Color(0xFFF1F7F3);
}
