import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_item_card.dart';

class StoresListView extends StatelessWidget {
  const StoresListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => AspectRatio(
        aspectRatio: 2,
          child: StoreItemCard()),
      separatorBuilder: (context, index) => 15.hSpace,
      itemCount: 5,
    );
  }
}