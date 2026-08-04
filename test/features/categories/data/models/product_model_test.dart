import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('name and description strings are localized into {ar, en} maps', () {
      final model = ProductModel.fromJson({
        'name': 'Pizza',
        'description': 'Tasty',
      });
      expect(model.name, {'ar': 'Pizza', 'en': 'Pizza'});
      expect(model.description, {'ar': 'Tasty', 'en': 'Tasty'});
    });

    test('images pull download_url from each entry and drop the ones missing it',
        () {
      final model = ProductModel.fromJson({
        'images': [
          {'download_url': 'a.png'},
          {'download_url': 'b.png'},
          {'thumb': 'no-url-here'},
        ],
      });
      expect(model.images, ['a.png', 'b.png']);
    });

    test('missing images defaults to an empty list, never null', () {
      expect(ProductModel.fromJson({'id': 1}).images, isEmpty);
    });

    test('price parses from a string and falls back to 0.0 when absent', () {
      expect(ProductModel.fromJson({'price': '12.50'}).price, 12.5);
      expect(ProductModel.fromJson({'price': 10}).price, 10.0);
      expect(ProductModel.fromJson({'id': 1}).price, 0.0);
    });

    test('nested active_deal is parsed when present, null when absent', () {
      final withDeal = ProductModel.fromJson({
        'active_deal': {'id': 9, 'discount_value': 15},
      });
      expect(withDeal.activeDeal, isNotNull);
      expect(withDeal.activeDeal!.id, 9);
      expect(withDeal.activeDeal!.discountValue, 15.0);

      expect(ProductModel.fromJson({'id': 1}).activeDeal, isNull);
    });

    test('nested vendor is parsed when present', () {
      final model = ProductModel.fromJson({
        'vendor': {
          'id': 3,
          'name': {'en': 'Shop', 'ar': 'متجر'},
        },
      });
      expect(model.vendor, isNotNull);
      expect(model.vendor!.id, 3);
    });
  });

  group('ProductModel.toJson', () {
    test('round-trips id, slug and the localized name', () {
      final round = ProductModel.fromJson({
        'id': 5,
        'slug': 'pizza',
        'name': 'Pizza',
      }).toJson();
      expect(round['id'], 5);
      expect(round['slug'], 'pizza');
      expect(round['name'], {'ar': 'Pizza', 'en': 'Pizza'});
    });
  });
}
