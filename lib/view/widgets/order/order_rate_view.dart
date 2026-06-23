import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/order/rating_card.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/text_fields/app_description_field.dart';

class OrderRateView extends StatelessWidget {
  const OrderRateView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context,rateConstraints) {
        return Container(
          height: rateConstraints.maxHeight*0.7,
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
                    'Rate',
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
                    spacing: 15,
                    children: [
                      RatingCard(title: 'How evaluate store?'),
                      RatingCard(title: 'How evaluate delivery?',),
                      AppDescriptionField(hintTxt: 'Tell us more ...'),
                    ],
                  ),
                ),
              ),
              5.hSpace,
              PrimaryAppButton(title: 'Send Rate')
            ],
          ),
        );
      }
    );
  }
}
