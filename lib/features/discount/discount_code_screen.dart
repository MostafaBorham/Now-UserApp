import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings/app_colors.dart';
import '../settings/components/profile_header.dart';
import 'components/discount_card.dart';

/// Discount Code screen.
///
/// Sections (see `components/`):
///   1. [CommonHeader]  – yellow header + wave + back button + title
///                         (shared with the Profile / Settings screens).
///   2. [DiscountCard] × N – a scrolling list of coupon "tickets"; the amber
///                           and dark color variants alternate down the list.
class DiscountCodeScreen extends StatelessWidget {
  const DiscountCodeScreen({super.key});

  static const double _hPadding = 20;

  static const List<DiscountCoupon> _coupons = [
    DiscountCoupon(
      percent: '20',
      scope: 'On all stores',
      title: 'Discount Code',
      validity: 'From January 10 to January 31, 2026',
      minPurchase: 'Minimum purchase 1',
      code: 'ST-V2586',
    ),
    DiscountCoupon(
      percent: '20',
      scope: 'On all stores',
      title: 'Discount Code',
      validity: 'From January 10 to January 31, 2026',
      minPurchase: 'Minimum purchase 1',
      code: 'ST-V2586',
    ),
    DiscountCoupon(
      percent: '20',
      scope: 'On all stores',
      title: 'Discount Code',
      validity: 'From January 10 to January 31, 2026',
      minPurchase: 'Minimum purchase 1',
      code: 'ST-V2586',
    ),
    DiscountCoupon(
      percent: '20',
      scope: 'On all stores',
      title: 'Discount Code',
      validity: 'From January 10 to January 31, 2026',
      minPurchase: 'Minimum purchase 1',
      code: 'ST-V2586',
    ),
    DiscountCoupon(
      percent: '20',
      scope: 'On all stores',
      title: 'Discount Code',
      validity: 'From January 10 to January 31, 2026',
      minPurchase: 'Minimum purchase 1',
      code: 'ST-V2586',
    ),
    DiscountCoupon(
      percent: '20',
      scope: 'On all stores',
      title: 'Discount Code',
      validity: 'From January 10 to January 31, 2026',
      minPurchase: 'Minimum purchase 1',
      code: 'ST-V2586',
    ),
  ];

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Code $code copied'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommonHeader(
            title: 'Discount Code',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(_hPadding, 20, _hPadding, 24),
              itemCount: _coupons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) => DiscountCard(
                coupon: _coupons[index],
                dark: index.isOdd,
                onCopy: () => _copyCode(context, _coupons[index].code),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
