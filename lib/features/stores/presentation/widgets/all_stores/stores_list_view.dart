import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';

class StoresListView extends StatelessWidget {
  const StoresListView({super.key});

  @override
  Widget build(BuildContext context) {
    // ponytail: renders 5 empty StoreItem placeholders — AllStoresScreen has no
    // data source yet (StoresRepo has no getStores). Wire a get-all-stores
    // viewmodel and pass real StoreModels when the endpoint is integrated.
    return ListView.separated(
      itemBuilder: (context, index) =>
          const AspectRatio(aspectRatio: 2, child: StoreItem()),
      separatorBuilder: (context, index) => 15.hSpace,
      itemCount: 5,
    );
  }
}
