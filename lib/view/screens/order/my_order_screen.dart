import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/order/order_list_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';

class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AppWavedScaffold(body: ListView.separated(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return OrderListItem();
      },
      separatorBuilder: (context, index) {
        return 20.hSpace;
      },
      itemCount: 5,
    ), appBarTitle: 'My Orders',);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.onSecondaryFixed,
            colors.onPrimary,
            colors.onPrimary,
          ],
        ),
      ),
      child: Column(
        spacing: 20,
        children: [
          AutoSizeText(
            'My Orders',
            style: AppTextStyles.style24SemiBold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Assets.media.images.svg.whiteWaveBackground.svg(
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 50.0,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return OrderListItem();
                    },
                    separatorBuilder: (context, index) {
                      return 20.hSpace;
                    },
                    itemCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
