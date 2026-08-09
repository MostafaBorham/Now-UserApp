import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';

import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import '../../../settings/presentation/widgets/profile_header.dart';
import '../widgets/discount_code/discount_card.dart';

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
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.discountTitle.tr(),
        body: Expanded(
          child: ListView.separated(
            itemCount: _coupons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) => DiscountCard(
              coupon: _coupons[index],
              dark: index.isOdd,
              onCopy: () => _copyCode(context, _coupons[index].code),
            ),
          ),
        ),
      ),
    );
  }
}
