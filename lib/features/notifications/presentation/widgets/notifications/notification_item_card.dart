import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    super.key,
    required this.leading,
    required this.title,
    required this.description,
    required this.time,
    required this.actionLabel,
    required this.isUnread,
    this.onActionTap,
  });

  final Widget leading;
  final String title;
  final String description;
  final String time;
  final String actionLabel;
  final bool isUnread;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: AppBorderRadius.brCircular12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.style16SemiBold.copyWith(
                          color: colors.tertiaryContainer,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  description,
                  maxLines: 3,
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.outline,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.outline,
                      ),
                    ),
                    InkWell(
                      onTap: onActionTap,
                      child: Text(
                        actionLabel,
                        style: AppTextStyles.style14Medium.copyWith(
                          color: colors.primary500Main,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
