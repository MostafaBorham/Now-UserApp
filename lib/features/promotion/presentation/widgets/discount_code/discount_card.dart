import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Data for a single discount coupon shown as a ticket card.
class DiscountCoupon {
  const DiscountCoupon({
    required this.percent,
    required this.scope,
    required this.title,
    required this.validity,
    required this.minPurchase,
    required this.code,
  });

  /// Discount amount without the percent sign, e.g. "20".
  final String percent;

  /// Where the coupon applies, e.g. "On all stores".
  final String scope;

  /// Card heading, e.g. "Discount Code".
  final String title;

  /// Validity window, e.g. "From January 10 to January 31, 2026".
  final String validity;

  /// Minimum-purchase requirement line.
  final String minPurchase;

  /// The redeemable code, e.g. "ST-V2586".
  final String code;
}

/// A discount coupon rendered as a perforated "ticket".
///
/// The left value panel shows the percentage and scope; the right body panel
/// shows the code details plus the vertical "now" brand logo. A semicircular
/// notch is punched into the top and bottom edges (see [_TicketClipper]) so
/// stacked cards read as tear-off tickets.
///
/// Two variants alternate down the list:
///   * [dark] == false → amber value panel on a mint body.
///   * [dark] == true  → dark-green value panel on a cream body.
class DiscountCard extends StatelessWidget {
  const DiscountCard({
    super.key,
    required this.coupon,
    this.dark = false,
    this.onCopy,
  });

  final DiscountCoupon coupon;
  final bool dark;

  /// Called when the code chip is tapped.
  final VoidCallback? onCopy;

  static const double _radius = 16;
  static const double _notchRadius = 17;

  /// Horizontal position of the perforation, as a fraction of the card width.
  static const double _notchFraction = 0.69;

  @override
  Widget build(BuildContext context) {
    final Color valuePanel = dark
        ? context.colors.surfaceBright
        : context.colors.surface;
    final Color bodyPanel = dark
        ? context.colors.secondary100
        : context.colors.primary100;
    final Color percentColor = dark
        ? context.colors.surface
        : context.colors.primaryContainer;
    final Color scopeColor = dark
        ? context.colors.white
        : context.colors.tertiaryContainer;

    return PhysicalShape(
      clipper: const _TicketClipper(
        radius: _radius,
        notchRadius: _notchRadius,
        notchFraction: _notchFraction,
      ),
      clipBehavior: Clip.antiAlias,
      color: bodyPanel,
      elevation: 1.5,
      shadowColor: const Color(0x14000000),
      child: AspectRatio(
        aspectRatio: 16 / 6,
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  height: constraints.maxHeight,
                  color: valuePanel,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: coupon.percent,
                            style: TextStyle(
                              fontSize: 40,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: percentColor,
                            ),
                            children: [
                              TextSpan(
                                text: '%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: percentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          coupon.scope,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: scopeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Body panel (right).
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  spacing: 6,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        coupon.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.primaryContainer,
                        ),
                      ),
                    ),

                    Text(
                      coupon.validity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: context.colors.neutral500,
                      ),
                    ),

                    Text(
                      coupon.minPurchase,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.neutral500,
                      ),
                    ),

                    _CodeChip(code: coupon.code, onCopy: onCopy),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14, left: 4),
              child: Center(
                child: Assets.media.images.svg.logoVertical.svg(
                  height: 64,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The rounded, copyable code pill (copy icon + code text).
class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code, this.onCopy});

  final String code;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: context.colors.primary100,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.media.images.svg.copy.svg(width: 16, height: 16),
            const SizedBox(width: 8),
            Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clips a rounded rectangle with a semicircular notch punched out of the
/// centre of its top and bottom edges, at [notchFraction] of the width — the
/// classic tear-off ticket silhouette.
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({
    required this.radius,
    required this.notchRadius,
    required this.notchFraction,
  });

  final double radius;
  final double notchRadius;
  final double notchFraction;

  @override
  Path getClip(Size size) {
    final double dx = size.width * notchFraction;
    final Path base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final Path notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(dx, 0), radius: notchRadius))
      ..addOval(
        Rect.fromCircle(center: Offset(dx, size.height), radius: notchRadius),
      );
    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchFraction != notchFraction;
}
