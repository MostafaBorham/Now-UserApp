import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/discount_code/discount_code_item.dart';
class DiscountCodeListItems extends StatelessWidget {
  const DiscountCodeListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => DiscountCodeItem(isDimmed: index == 0,),
      separatorBuilder: (context, index) => 16.wSpace,
      itemCount: 4,
    );
  }
}
