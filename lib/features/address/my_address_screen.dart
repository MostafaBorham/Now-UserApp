import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

import '../settings/app_colors.dart';
import '../settings/components/profile_header.dart';
import 'components/add_address_button.dart';
import 'components/address_card.dart';

/// "My Address" screen.
///
/// Composed of independent sections (see `components/`):
///   1. [CommonHeader]     – yellow header + wave + back button + title
///                            (shared with the Profile / Settings screens).
///   2. [AddressCard] × N   – one selectable card per saved address; the
///                            selected card is the default one and is
///                            highlighted with a soft green gradient.
///   3. [AddAddressButton]  – green call-to-action to add a new address.
class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({super.key});

  @override
  State<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  /// Gap between the two address cards.
  static const double _cardGap = 16;

  final List<_Address> _addresses = const [
    _Address(title: 'Home', address: 'Al Nahda 2, Dubai, United Arab Emirates'),
    _Address(
      title: 'Office',
      address: 'Business Bay, Dubai, United Arab Emirates',
    ),
  ];

  /// Index of the currently selected (default) address.
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedScaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < _addresses.length; i++) ...[
                if (i > 0) const SizedBox(height: _cardGap),
                AddressCard(
                  title: _addresses[i].title,
                  address: _addresses[i].address,
                  isDefault: i == _selected,
                  onSelect: () => setState(() => _selected = i),
                  onEdit: () => context.pushNamed(
                    AppRoutes.addressDetailsScreen,
                    extra: true,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AddAddressButton(
                onPressed: () =>
                    context.pushNamed(AppRoutes.addNewAddressFromMapScreen),
              ),
            ],
          ),
        ),
        appBarTitle: LangKeys.addressKey.tr(),
      ),
    );
  }
}

/// Lightweight model backing a single [AddressCard].
class _Address {
  const _Address({required this.title, required this.address});

  final String title;
  final String address;
}
