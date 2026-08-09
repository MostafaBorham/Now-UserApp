import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/favourites/data/datasources/remote/api/favourites_endpoints.dart';

void main() {
  group('FavouritesEndpoints paths', () {
    test('list and category-chip paths', () {
      expect(FavouritesEndpoints.getFavourites, '/api/v1/favorites');
      expect(
        FavouritesEndpoints.getFavouriteCategories,
        '/api/v1/favorites/categories',
      );
    });
  });

  group('getFavouritesQuery', () {
    test('always carries type, per_page and page; omits unset filters', () {
      expect(
        FavouritesEndpoints.getFavouritesQuery(type: 'product', page: 1),
        <String, dynamic>{'type': 'product', 'per_page': 15, 'page': 1},
      );
    });

    test('includes search only when non-empty', () {
      expect(
        FavouritesEndpoints.getFavouritesQuery(
          type: 'product',
          page: 1,
          search: 'shoes',
        )['search'],
        'shoes',
      );
      expect(
        FavouritesEndpoints.getFavouritesQuery(
          type: 'product',
          page: 1,
          search: '',
        ).containsKey('search'),
        isFalse,
      );
    });

    test('includes category_ids only when non-empty', () {
      expect(
        FavouritesEndpoints.getFavouritesQuery(
          type: 'vendor',
          page: 2,
          categoryIds: <int>[1, 2],
        )['category_ids'],
        <int>[1, 2],
      );
      expect(
        FavouritesEndpoints.getFavouritesQuery(
          type: 'vendor',
          page: 2,
          categoryIds: const <int>[],
        ).containsKey('category_ids'),
        isFalse,
      );
    });

    test('includes sort only when set', () {
      expect(
        FavouritesEndpoints.getFavouritesQuery(
          type: 'product',
          page: 1,
          sort: 'price_asc',
        )['sort'],
        'price_asc',
      );
      expect(
        FavouritesEndpoints.getFavouritesQuery(type: 'product', page: 1)
            .containsKey('sort'),
        isFalse,
      );
    });
  });

  group('getFavouriteCategoriesQuery', () {
    test('carries the type', () {
      expect(
        FavouritesEndpoints.getFavouriteCategoriesQuery(type: 'vendor'),
        <String, dynamic>{'type': 'vendor'},
      );
    });
  });
}
