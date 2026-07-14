import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';

import '../components/cancel_order_bottom_sheet.dart';
import '../components/courier_section.dart';
import '../components/delivery_details_section.dart';
import '../components/item_information_section.dart';
import '../components/order_timeline_section.dart';
import '../components/track_order_number_header.dart';

/// Track Order screen: order summary, item & delivery details, the courier
/// contact card and the live delivery timeline, with a cancel action.
class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        appBarTitle: LangKeys.trackOrderKey.tr(),
        canPop: true,
        body: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              const TrackOrderNumberHeader(),
              const ItemInformationSection(),
              const DeliveryDetailsSection(),
              const CourierSection(),
              const OrderTimelineSection(),
              4.hSpace,
              PrimaryButton(
                title: LangKeys.cancelOrderKey.tr(),
                buttonColor: colors.errorContainer,
                titleColor: colors.onPrimary,
                buttonPadding: 16,
                onTap: () => CancelOrderBottomSheet.show(context),
              ),
              8.hSpace,
            ],
          ),
        ),
      ),
    );
  }
}
