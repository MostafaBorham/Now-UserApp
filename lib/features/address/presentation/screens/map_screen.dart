import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/add_address_button.dart';
import 'package:nowdelivery_user_app/features/settings/components/profile_header.dart';

class AddNewAddressFromMap extends StatelessWidget {
  const AddNewAddressFromMap({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.addNewAddress.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: ArrowBackButton(onTap: () => context.pop()),
        actions: [Assets.media.images.svg.search.svg()],
      ),
      body: AppMap(),
      persistentFooterDecoration: BoxDecoration(
        color: colors.onPrimary
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [PrimaryAppButton(title: 'Enter address',onTap: () {

      },)],
    );
  }
}

class AppMap extends StatefulWidget {
  const AppMap({super.key});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late GoogleMapController _mapController;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  // Load the styling JSON from application assets
  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString(Assets.json.map);
    if (!mounted) return;
    setState(() {
      _mapStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      style: _mapStyle,
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(30.115508, 31.403403),
      ),

      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }
}