import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class DeliveryAddressCard extends StatelessWidget {
  const DeliveryAddressCard({
    super.key,
    this.title = 'Delivery Address',
    this.address = '7468 Olaya, Riyadh',
    this.onEdit,
  });

  final String title;
  final String address;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              InkWell(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            address,
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
