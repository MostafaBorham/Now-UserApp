import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/enums/online_card_types.dart';
import 'package:nowdelivery_user_app/common/params/online_card_params.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/add_card_form.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/online_card_radio_selector.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/payment_method_selector.dart';import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/money_amount_picker.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
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
                'Add Card',
                style: AppTextStyles.style18Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
              IconButton(padding: EdgeInsetsGeometry.zero,visualDensity: VisualDensity.compact, onPressed: () {
                Navigator.pop(context);
              }, icon: Icon(Icons.clear,size: 20.sp,color: colors.onSecondary,))
            ],
          ),
          AddCardForm(),
          2.hSpace,
          PrimaryAppButton(title: 'Add',)
        ],
      ),
    );
  }
}