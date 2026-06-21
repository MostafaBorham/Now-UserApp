import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/payment_method_selector.dart';import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/money_amount_picker.dart';

class AddMoneyView extends StatefulWidget {
  const AddMoneyView({super.key});

  @override
  State<AddMoneyView> createState() => _AddMoneyViewState();
}

class _AddMoneyViewState extends State<AddMoneyView> {
  String? moneyAmount;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0,horizontal: 16 ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              AutoSizeText(
                'Add Money',
                style: AppTextStyles.style18Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
              IconButton(padding: EdgeInsetsGeometry.zero,visualDensity: VisualDensity.compact, onPressed: () {
                Navigator.pop(context);
              }, icon: Icon(Icons.clear,size: 20.sp,color: colors.onSecondary,))
            ],
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                PaymentMethodSelector(
                  initialIndex: 0,
                  onChanged: (i) => debugPrint('selected $i'),
                ),
                MoneyAmountPicker(
                  maxAmount: 5000,
                  onAmountChanged: (amount) {
                    moneyAmount = amount;
                    setState(() {

                    });
                    debugPrint('selected amount ==== $amount');
                  },
                ),
              ],
            ),
          ),
          5.hSpace,
          (moneyAmount!=null && moneyAmount!.isNotEmpty) ? PrimaryAppButton(title: 'Continue',) : PrimaryAppDisabledButton(title: 'Continue')
        ],
      ),
    );
  }
}
