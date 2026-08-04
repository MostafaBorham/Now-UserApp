import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

void main() {
  group('JsonParsing.localized', () {
    test('a bare String is mirrored into both locales', () {
      expect({'name': 'Food'}.localized('name'), {'ar': 'Food', 'en': 'Food'});
    });

    test('an existing translation map is returned unchanged', () {
      final map = {'ar': 'طعام', 'en': 'Food'};
      expect({'name': map}.localized('name'), map);
    });

    test('a missing key is null', () {
      expect(<String, dynamic>{}.localized('name'), isNull);
    });

    test('an explicit null value is null', () {
      expect({'name': null}.localized('name'), isNull);
    });
  });

  group('JsonParsing.downloadUrl', () {
    test('extracts download_url from the nested object', () {
      expect(
        {
          'image': {'download_url': 'https://cdn/x.png'},
        }.downloadUrl('image'),
        'https://cdn/x.png',
      );
    });

    test('a missing image key is null', () {
      expect(<String, dynamic>{}.downloadUrl('image'), isNull);
    });

    test('an image object without download_url is null', () {
      expect(
        {
          'image': {'width': 100},
        }.downloadUrl('image'),
        isNull,
      );
    });
  });
}
