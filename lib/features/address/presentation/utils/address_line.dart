import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// An address as one line in the app's language, built from its columns.
///
/// Shown instead of the backend's `full_address`, which joins them with
/// English "Floor"/"Apartment" and ASCII commas whatever the language — mixed
/// into Arabic, the line came out scrambled. A Work address keeps its company
/// name in `apartment`, so it is shown bare. The city is left out when the
/// area already names it, as a geocoded area usually does.
String addressLine(BuildContext context, AddressModel address) {
  final bool isWork = address.label?['en'] == 'Work';
  final String? floor = _filled(address.floor);
  final String? apartment = _filled(address.apartment);
  final String? area = _filled(address.area);
  final String? city = _filled(address.city);

  return <String?>[
    _filled(address.street),
    _filled(address.buildingNumber),
    if (floor != null) LangKeys.floorValueKey.tr(args: <String>[floor]),
    if (apartment != null)
      isWork
          ? apartment
          : LangKeys.apartmentValueKey.tr(args: <String>[apartment]),
    area,
    if (city != null && !(area?.contains(city) ?? false)) city,
  ].whereType<String>().join(context.isRTL ? '، ' : ', ');
}

String? _filled(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
