import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/geocoding_repo.dart';

/// Pinning a point offline used to wait out the geocoder and then say "move
/// the pin", as if the point were the problem.
void main() {
  const LatLng point = LatLng(24.7136, 46.6753);
  const Placemark placemark = Placemark(
    street: 'King Fahd Rd',
    subLocality: 'Olaya',
    locality: 'Riyadh',
    country: 'Saudi Arabia',
  );

  String? failureOf(Either<Failure, AddressModel> result) =>
      result.fold((Failure f) => f.message, (_) => null);

  test('offline: says to check the connection, without geocoding', () async {
    int lookups = 0;
    final GeocodingRepo repo = GeocodingRepo(
      isConnected: () async => false,
      placemarkAt: (_) async {
        lookups++;
        return placemark;
      },
    );

    final result = await repo.addressAt(point);

    expect(failureOf(result), LangKeys.noInternetConnectionKey);
    expect(lookups, 0);
  });

  test('connection lost during the lookup: still a connection message',
      () async {
    final List<bool> connectivity = <bool>[true, false];
    final GeocodingRepo repo = GeocodingRepo(
      isConnected: () async => connectivity.removeAt(0),
      placemarkAt: (_) async => null,
    );

    final result = await repo.addressAt(point);

    expect(failureOf(result), LangKeys.noInternetConnectionKey);
  });

  test('online with no address at the point: asks to move the pin', () async {
    final GeocodingRepo repo = GeocodingRepo(
      isConnected: () async => true,
      placemarkAt: (_) async => null,
    );

    final result = await repo.addressAt(point);

    expect(failureOf(result), LangKeys.failedToGetAddress);
  });

  test('online with an address: returns it', () async {
    final GeocodingRepo repo = GeocodingRepo(
      isConnected: () async => true,
      placemarkAt: (_) async => placemark,
    );

    final result = await repo.addressAt(point);

    expect(failureOf(result), isNull);
    expect(result.isRight(), isTrue);
  });
}
