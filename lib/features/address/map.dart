import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/features/address/components/add_address_button.dart';
import 'package:nowdelivery_user_app/features/settings/components/profile_header.dart';

class AddNewAddressFromMap extends StatelessWidget {
  const AddNewAddressFromMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new address"),
        centerTitle: true,
        leading: ArrowBackButton(onTap: () => Navigator.of(context).maybePop()),
        actions: [Assets.media.images.svg.search.svg()],
      ),
      body: Assets.media.images.png.map.image(
        height: double.maxFinite,
        width: double.maxFinite,
        fit: BoxFit.cover,
      ),
      persistentFooterButtons: [AddAddressButton(onPressed: () {})],
    );
  }
}
