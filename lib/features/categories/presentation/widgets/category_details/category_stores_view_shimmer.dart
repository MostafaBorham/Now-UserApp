import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';

class CategoryStoresViewShimmer extends StatelessWidget {
  const CategoryStoresViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(4),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (BuildContext context, int index) => 20.hSpace,
      itemBuilder: (BuildContext context, int index) => const AspectRatio(
        aspectRatio: 1.75,
        child: AppShimmer(child: StoreCardView()),
      ),
    );
  }
}
