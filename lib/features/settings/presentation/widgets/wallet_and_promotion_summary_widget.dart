import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

/// Green glass card under the profile header summarising the reward points
/// balance (start side) and the wallet balance (end side).
///
/// The wallet balance is refreshed when the card opens. Reward points stay
/// blank until the app has a real balance to display.
class WalletAndPromotionSummaryWidget extends ConsumerStatefulWidget {
  const WalletAndPromotionSummaryWidget({super.key});

  @override
  ConsumerState<WalletAndPromotionSummaryWidget> createState() =>
      _WalletAndPromotionSummaryWidgetState();
}

class _WalletAndPromotionSummaryWidgetState
    extends ConsumerState<WalletAndPromotionSummaryWidget> {
  static const String _placeholder = '--';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(getWalletInfoProvider.notifier).getWalletInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double? balance = ref
        .watch(getWalletInfoProvider)
        .valueOrNull
        ?.balance;
    final TextStyle valueStyle = AppTextStyles.style14Bold.copyWith(
      color: colors.white,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.white.withValues(alpha: 0.25)),
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerEnd,
          end: AlignmentDirectional.centerStart,
          colors: [colors.primary700, colors.primary500Main, colors.primary700],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary700.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Diagonal sheen across the card — the "glass" highlight.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.white.withValues(alpha: 0.22),
                      colors.white.withValues(alpha: 0.04),
                      colors.white.withValues(alpha: 0),
                      colors.white.withValues(alpha: 0.10),
                    ],
                    stops: const [0, 0.35, 0.65, 1],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    iconAsset: Assets.media.images.svg.promotionIcon.path,
                    label: LangKeys.rewardPointsBalanceKey.tr(),
                    value: Text(_placeholder, style: valueStyle),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: colors.white.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: _SummaryItem(
                    iconAsset: Assets.media.images.svg.wallet2.path,
                    label: LangKeys.walletBalanceKey.tr(),
                    onTap: () => context.pushNamed(AppRoutes.walletScreen),
                    value: balance == null
                        ? Text(_placeholder, style: valueStyle)
                        : NewPriceWidget(
                            color: colors.white,
                            size: 16,
                            fontWeight: FontWeight.w700,
                            price: formatMoney(balance),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass icon circle followed by a small label over its value.
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.iconAsset,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String iconAsset;
  final String label;
  final Widget value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          _GlassIconCircle(iconAsset: iconAsset),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style10Medium.copyWith(
                    color: colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted-glass circle: blurs the card behind it, tints it with a soft white
/// fill lit from the top-left and rims it with a cut stroke (see
/// [_GlassRimPainter]).
class _GlassIconCircle extends StatelessWidget {
  const _GlassIconCircle({required this.iconAsset});

  static const double _size = 44;

  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    final Color white = context.colors.white;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: CustomPaint(
          foregroundPainter: _GlassRimPainter(white),
          child: Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.45, -0.55),
                radius: 1.1,
                colors: [
                  white.withValues(alpha: 0.35),
                  white.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: SvgPicture.asset(
              iconAsset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

/// The glass rim: a circle stroke shaded along the top-left → bottom-right
/// diagonal, bright on the lit top-left arc, softer on the bottom-right one and
/// fading to nothing in between — so the ring reads as cut, not a full white
/// border.
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter(this.color);

  static const double _strokeWidth = 1.2;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0),
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.55),
        ],
        stops: const [0, 0.4, 0.6, 1],
      ).createShader(rect);
    canvas.drawOval(rect.deflate(_strokeWidth / 2), paint);
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      oldDelegate.color != color;
}
