import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/notifications/presentation/widgets/notifications/notification_item_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Scaffold(
      body: AppWavedView(
        appBarTitle: context.tr(LangKeys.notificationsKey),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(
                    context.tr(LangKeys.todayKey),
                    style: AppTextStyles.style18Medium.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                  NotificationItemCard(
                    isUnread: true,
                    title: 'Order Delivery',
                    description:
                        'Your grocery order #9821 is on its way. Estimated arrival: within 15 minutes.',
                    time: context.tr(LangKeys.justNowKey),
                    actionLabel: context.tr(LangKeys.trackOrderKey),
                    onActionTap: () {},
                    leading: ReverseWidget(
                      applyReverse: context.isRTL,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.tertiaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: Assets.media.images.svg.deliveryIcon.svg(
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            colors.onSecondaryContainer,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(
                    context.tr(LangKeys.yesterdayKey),
                    style: AppTextStyles.style18Medium.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                  NotificationItemCard(
                    isUnread: false,
                    title: 'Order Delivery',
                    description:
                        'Your grocery order #9821 is on its way. Estimated arrival: within 15 minutes.',
                    time: 'Mar 10, 2026',
                    actionLabel: context.tr(LangKeys.shopNowKey),
                    onActionTap: () {},
                    leading: Container(
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: colors.onTertiaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surfaceContainerLow),
                      ),
                      child: AppCachedNetworkImage(
                        imageUrl:
                            'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  NotificationItemCard(
                    isUnread: false,
                    title: 'Order Delivery',
                    description:
                        'Your grocery order #9821 is on its way. Estimated arrival: within 15 minutes.',
                    time: 'Mar 10, 2026',
                    actionLabel: context.tr(LangKeys.shopNowKey),
                    onActionTap: () {},
                    leading: Container(
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: colors.onTertiaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surfaceContainerLow),
                      ),
                      child: AppCachedNetworkImage(
                        imageUrl:
                            'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
