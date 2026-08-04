import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

import 'labeled_detail_row.dart';
import 'tracking_section_card.dart';

/// "Delivery Details" section: receiver, address, contact, store, item count,
/// the chosen payment method and the amount to pay.
class DeliveryDetailsSection extends StatelessWidget {
  const DeliveryDetailsSection({
    super.key,
    this.receiver = 'Yaseer Ahmed',
    this.address = '7468 Olaya, Riyadh',
    this.contact = '+966 5 1234 5678',
    this.store = 'Panda Store',
    this.itemsCount = 1,
    this.paymentMethod = 'Visa ****0442',
    this.amount = '20.00',
  });

  final String receiver;
  final String address;
  final String contact;
  final String store;
  final int itemsCount;
  final String paymentMethod;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return TrackingSectionCard(
      title: LangKeys.deliveryDetailsKey.tr(),
      child: Column(
        spacing: 14,
        children: [
          LabeledDetailRow(label: LangKeys.receiverKey.tr(), value: receiver),
          LabeledDetailRow(label: LangKeys.addressKey.tr(), value: address),
          LabeledDetailRow(label: LangKeys.contactKey.tr(), value: contact),
          LabeledDetailRow(label: LangKeys.storeKey.tr(), value: store),
          LabeledDetailRow(
            label: LangKeys.numberOfItemsKey.tr(),
            value: '$itemsCount',
          ),
          LabeledDetailRow(
            label: LangKeys.paymentKey.tr(),
            value: paymentMethod,
          ),
          LabeledDetailRow(
            label: LangKeys.payKey.tr(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.media.images.svg.realSaudiCurrency.svg(
                  width: 14,
                  height: 14,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    colors.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                5.wSpace,
                Text(
                  amount,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.onSecondary,
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
