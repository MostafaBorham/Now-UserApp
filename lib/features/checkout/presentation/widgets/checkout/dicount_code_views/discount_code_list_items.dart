import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/dicount_code_views/discount_code_item.dart';

class DiscountCodeListItems extends StatelessWidget {
  const DiscountCodeListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => DiscountCodeItem(),
      separatorBuilder: (context, index) => 5.wSpace,
      itemCount: 4,
    );
  }
}
