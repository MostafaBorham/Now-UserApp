import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        actions: [SvgPicture.asset("assets/svg/search.svg")],
      ),
      body: Image.asset(
        "assets/svg/09.jpg",
        height: double.maxFinite,
        fit: BoxFit.cover,
      ),
      persistentFooterButtons: [AddAddressButton(onPressed: () {})],
    );
  }
}
