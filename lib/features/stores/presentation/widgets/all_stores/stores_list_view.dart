import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

class StoresListView extends StatelessWidget {
  const StoresListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 2),
      itemBuilder: (context, index) =>
          AspectRatio(aspectRatio: 1.5, child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.pushNamed(AppRoutes.storeDetailsScreen,),
              child: StoreCardView())),
      separatorBuilder: (context, index) => 15.hSpace,
      itemCount: 5,
    );
  }
}
