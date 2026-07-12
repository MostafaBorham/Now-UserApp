import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';

class CategoryStoresViewShimmer extends StatelessWidget {
  const CategoryStoresViewShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => AspectRatio(
          aspectRatio: 2,
          child: AppShimmer(
            child: StoreItem(
              // storeModel: stores.elementAtOrNull(index),
            ),
          )),
      separatorBuilder: (context, index) => 20.hSpace,
      itemCount: 3,
    );
  }
}