import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

/// Pins the two shapes [AddressModel] serializes into, which are deliberately
/// not the same one.
///
/// [AddressModel.toJson] mirrors the server's own keys so an address can be
/// cached and read back whole. [AddressModel.toRequestJson] is narrower: it
/// sends only the fields a client owns, flattens the label to its English
/// value, and converts the coordinates the read model holds as strings back
/// into numbers. Getting either wrong writes bad data rather than failing
/// loudly, so both are pinned here.
void main() {
  const Map<String, dynamic> serverJson = <String, dynamic>{
    'id': 12,
    'user_id': 3,
    'label': <String, dynamic>{'en': 'Home', 'ar': 'المنزل'},
    'phone': '0512345678',
    'country': 'Saudi Arabia',
    'city': 'Riyadh',
    'area': 'Al Olaya',
    'street': 'King Fahd Road',
    'building_number': '12',
    'floor': '3',
    'apartment': '7',
    'latitude': '24.7136',
    'longitude': '46.6753',
    'notes': 'Ring twice',
    'is_default': true,
    'full_address': 'Al Olaya, King Fahd Road, Riyadh',
    'created_at': '2026-01-04T10:00:00Z',
    'updated_at': '2026-02-11T09:30:00Z',
    'deleted_at': null,
  };

  group('toRequestJson', () {
    test('the label is sent as its English value, not the whole map', () {
      final Map<String, dynamic> body = AddressModel.fromJson(
        serverJson,
      ).toRequestJson();

      // The backend owns the translation; it stores what this sends. Changing
      // AddressModel.labelOptions therefore changes stored data, not just copy.
      expect(body['label'], 'Home');
    });

    test('every labelOption survives the flattening', () {
      for (final Map<String, String> option in AddressModel.labelOptions) {
        final AddressModel address = AddressModel(label: option);
        expect(address.toRequestJson()['label'], option['en']);
      }
    });

    test('coordinates are sent as numbers, not the strings we hold', () {
      final Map<String, dynamic> body = AddressModel.fromJson(
        serverJson,
      ).toRequestJson();

      expect(body['latitude'], isA<double>());
      expect(body['longitude'], isA<double>());
      expect(body['latitude'], closeTo(24.7136, 1e-9));
      expect(body['longitude'], closeTo(46.6753, 1e-9));
    });

    test('an unparseable coordinate becomes null rather than throwing', () {
      const AddressModel address = AddressModel(
        latitude: 'not-a-number',
        longitude: null,
      );

      final Map<String, dynamic> body = address.toRequestJson();

      expect(body['latitude'], isNull);
      expect(body['longitude'], isNull);
    });

    test('server-owned fields are never sent back', () {
      final Map<String, dynamic> body = AddressModel.fromJson(
        serverJson,
      ).toRequestJson();

      for (final String key in <String>[
        'id',
        'user_id',
        'full_address',
        'created_at',
        'updated_at',
        'deleted_at',
      ]) {
        expect(
          body.containsKey(key),
          isFalse,
          reason: '$key is assigned by the server and must not be sent',
        );
      }
    });

    test('is_default falls back to false when the model has none', () {
      // A first address is therefore created as non-default. Whether the
      // backend promotes it is the backend's call, not this model's.
      expect(const AddressModel().toRequestJson()['is_default'], isFalse);
    });
  });

  group('fromJson', () {
    test('a bare-string label is widened to a translation map', () {
      // Some endpoints answer with a plain string where others send the map;
      // widening here keeps `context.getLocalizedApiText` working for both.
      final AddressModel address = AddressModel.fromJson(<String, dynamic>{
        'label': 'Work',
      });

      expect(address.label, <String, dynamic>{'ar': 'Work', 'en': 'Work'});
    });

    test('a null payload yields an empty address instead of throwing', () {
      expect(AddressModel.fromJson(null), const AddressModel());
    });

    test('a full payload round-trips through toJson unchanged', () {
      expect(AddressModel.fromJson(serverJson).toJson(), serverJson);
    });
  });

  group('fromPlacemark', () {
    const LatLng pin = LatLng(24.1, 47.3);

    test('fills the fields the server requires when the platform leaves '
        'street and city empty', () {
      // An unnamed road outside a city: what iOS (no postal street) and
      // Android (no locality) hand back. The form lets the user type neither.
      final AddressModel address = AddressModel.fromPlacemark(
        const Placemark(
          country: 'Saudi Arabia',
          street: '',
          thoroughfare: '',
          name: '8Q7X+2C',
          subAdministrativeArea: 'Al Kharj',
          administrativeArea: 'Riyadh Province',
        ),
        pin,
      );

      expect(address.country, 'Saudi Arabia');
      expect(address.city, 'Al Kharj');
      expect(address.area, 'Riyadh Province');
      expect(address.street, '8Q7X+2C');
    });

    test('keeps the placemark\'s own street and city when it has them', () {
      final AddressModel address = AddressModel.fromPlacemark(
        const Placemark(
          country: 'Saudi Arabia',
          street: 'King Fahd Road',
          locality: 'Riyadh',
          subLocality: 'Al Olaya',
          administrativeArea: 'Riyadh Province',
        ),
        pin,
      );

      expect(address.city, 'Riyadh');
      expect(address.street, 'King Fahd Road');
      expect(address.area, 'Al Olaya - Riyadh - Riyadh Province');
    });
  });
}
