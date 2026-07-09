import 'package:flutter/material.dart';

import '../settings/app_colors.dart';
import '../settings/components/profile_header.dart';
import 'address_details_screen.dart';
import 'components/add_address_button.dart';
import 'components/address_card.dart';
import 'map.dart';

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
  /// Horizontal padding shared by the cards and the button.
  static const double _hPadding = 20;

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
      body: Column(
        children: [
          CommonHeader(
            title: 'My Address',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_hPadding, 20, _hPadding, 24),
              child: Column(
                children: [
                  for (int i = 0; i < _addresses.length; i++) ...[
                    if (i > 0) const SizedBox(height: _cardGap),
                    AddressCard(
                      title: _addresses[i].title,
                      address: _addresses[i].address,
                      isDefault: i == _selected,
                      onSelect: () => setState(() => _selected = i),
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddressDetailsScreen(isEditing: true),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AddAddressButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddNewAddressFromMap(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
