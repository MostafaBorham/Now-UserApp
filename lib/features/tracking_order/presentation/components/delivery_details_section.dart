import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

import 'labeled_detail_row.dart';
import 'tracking_section_card.dart';

/// "Delivery Details" section: receiver, address, contact, store, item count,
/// and the chosen payment method. The amounts sit in the invoice card below.
class DeliveryDetailsSection extends StatelessWidget {
  const DeliveryDetailsSection({
    super.key,
    required this.receiver,
    required this.address,
    required this.contact,
    required this.store,
    required this.itemsCount,
    required this.paymentMethod,
  });

  final String receiver;
  final String address;
  final String contact;
  final String store;
  final int itemsCount;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return TrackingSectionCard(
      title: LangKeys.deliveryDetailsKey.tr(),
      children: [
        Column(
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
          ],
        ),
      ],
    );
  }
}
