import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_card_shimmer.dart';

/// Full loading view for the "My Address" screen.
///
/// Self-contained: renders a non-scrolling list of [AddressCardShimmer]
/// placeholders followed by the "add new address" button placeholder, so the
/// screen only needs to place a single instance of this widget in its loading
/// branch.
class MyAddressesShimmerView extends StatelessWidget {
  const MyAddressesShimmerView({super.key, this.itemCount = 4});

  /// Number of shimmer cards to render.
  final int itemCount;

  static const double _cardGap = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(height: _cardGap),
          itemBuilder: (_, _) => const AddressCardShimmer(),
        ),
        AppShimmer(
          child: PrimaryAppButton(title: 'add new adesss', buttonPadding: 16),
        ),
      ],
    );
  }
}
