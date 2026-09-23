import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

import 'labeled_detail_row.dart';
import 'tracking_section_card.dart';

/// "Delivery Details" section: receiver, address, contact, store, item count,
/// the chosen payment method and the amount to pay.
class DeliveryDetailsSection extends StatelessWidget {
  const DeliveryDetailsSection({
    super.key,
    required this.receiver,
    required this.address,
    required this.contact,
    required this.store,
    required this.itemsCount,
    required this.paymentMethod,
    required this.amount,
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
            trailing: NewPriceWidget(
              color: colors.black,
              size: 14,
              fontWeight: FontWeight.w600,
              price: amount,
            ),
          ),
        ],
      ),
    );
  }
}
