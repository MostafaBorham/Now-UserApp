import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';

class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return AppWavedScaffold(
      body: ListView.separated(
        padding: EdgeInsets.all(3),
        itemBuilder: (context, index) {
          return AspectRatio(
              aspectRatio: 2,
              child: OrderListItem());
        },
        separatorBuilder: (context, index) {
          return 20.hSpace;
        },
        itemCount: 5,
      ),
      appBarTitle: LangKeys.myOrdersKey.tr(),
    );
  }
}
