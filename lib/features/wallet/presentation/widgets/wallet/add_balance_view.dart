import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/common/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/payment_method_selector.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/money_amount_picker.dart';

class AddBalanceView extends StatefulWidget {
  const AddBalanceView({super.key});

  @override
  State<AddBalanceView> createState() => _AddBalanceViewState();
}

class _AddBalanceViewState extends State<AddBalanceView> {
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
                LangKeys.addBalanceKey.tr(),
                style: AppTextStyles.style18Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
              IconButton(padding: EdgeInsetsGeometry.zero,visualDensity: VisualDensity.compact, onPressed: () {
                Navigator.pop(context);
              }, icon: Icon(Icons.clear,size: 20.sp,color: colors.onSecondary,))
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
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
          ),
          5.hSpace,
          (moneyAmount!=null && moneyAmount!.isNotEmpty) ? PrimaryAppButton(title: LangKeys.continueKey.tr(),) : PrimaryAppDisabledButton(title: LangKeys.continueKey.tr())
        ],
      ),
    );
  }
}
