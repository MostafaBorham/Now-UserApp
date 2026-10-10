import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';

void main() {
  group('CategoryModel.fromJson', () {
    test('null json returns an all-null model, not a throw', () {
      final model = CategoryModel.fromJson(null);
      expect(model.id, isNull);
      expect(model.name, isNull);
      expect(model.image, isNull);
    });

    test('a bare String name is mirrored into an {ar, en} map', () {
      final model = CategoryModel.fromJson({'name': 'Food'});
      expect(model.name, {'ar': 'Food', 'en': 'Food'});
    });

    test('an {ar, en} name map is passed through unchanged', () {
      final model = CategoryModel.fromJson({
        'name': {'ar': 'طعام', 'en': 'Food'},
      });
      expect(model.name, {'ar': 'طعام', 'en': 'Food'});
    });

    test('image is read from the nested download_url', () {
      final model = CategoryModel.fromJson({
        'image': {'download_url': 'https://cdn/x.png'},
      });
      expect(model.image, 'https://cdn/x.png');
    });

    test('a home-feed item\'s bare image_url is read as the image', () {
      final model = CategoryModel.fromJson({
        'id': 13,
        'type': 'category',
        'slug': 'books',
        'image_url': 'https://cdn/books.png?v=1',
        'primary_color': '#FF8800',
      });
      expect(model.image, 'https://cdn/books.png?v=1');
    });

    test('an image object wins over image_url', () {
      final model = CategoryModel.fromJson({
        'image': {'download_url': 'https://cdn/x.png'},
        'image_url': 'https://cdn/other.png',
      });
      expect(model.image, 'https://cdn/x.png');
    });

    test('missing image is null', () {
      expect(CategoryModel.fromJson({'slug': 'x'}).image, isNull);
    });

    test('primary_color is parsed; missing or malformed is null', () {
      expect(
        CategoryModel.fromJson({'primary_color': '#4BB749'}).primaryColor,
        const Color(0xFF4BB749),
      );
      expect(CategoryModel.fromJson({}).primaryColor, isNull);
      expect(
        CategoryModel.fromJson({'primary_color': 'green'}).primaryColor,
        isNull,
      );
    });

    test('numeric fields are coerced from num', () {
      final model = CategoryModel.fromJson({
        'id': 7,
        'descendants_count': 3,
        'products_count': 12,
      });
      expect(model.id, 7);
      expect(model.descendantsCount, 3);
      expect(model.productsCount, 12);
    });
  });

  group('CategoryModel.toJson', () {
    test('round-trips slug, name and image', () {
      final json = {
        'name': {'ar': 'طعام', 'en': 'Food'},
        'slug': 'food',
        'image': {'download_url': 'https://cdn/x.png'},
      };
      final round = CategoryModel.fromJson(json).toJson();
      expect(round['slug'], 'food');
      expect(round['name'], {'ar': 'طعام', 'en': 'Food'});
      expect(round['image'], {'download_url': 'https://cdn/x.png'});
    });

    test('primary_color survives the cache round-trip', () {
      const Color translucent = Color(0x0A4BB749);
      final round = CategoryModel.fromJson(
        const CategoryModel(primaryColor: translucent).toJson(),
      );
      expect(round.primaryColor, translucent);
    });

    test('null descendants_count is written as 0', () {
      expect(const CategoryModel().toJson()['descendants_count'], 0);
    });

    test('null image is written as null, not an empty object', () {
      expect(const CategoryModel().toJson()['image'], isNull);
    });
  });

  group('CategoryModel equality (Equatable)', () {
    test('two models with the same fields are equal', () {
      expect(
        const CategoryModel(id: 1, slug: 'a'),
        const CategoryModel(id: 1, slug: 'a'),
      );
    });

    test('differing slug breaks equality', () {
      expect(
        const CategoryModel(id: 1, slug: 'a'),
        isNot(const CategoryModel(id: 1, slug: 'b')),
      );
    });
  });
}
