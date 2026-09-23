import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/stores/data/datasources/remote/api/stores_endpoints.dart';

/// The store-products query is what scopes a category chip to the store the
/// shopper is looking at. It used to build itself from static fields that the
/// API service assigned — and `category_id` was assigned but never emitted, so
/// the chip silently listed the category across every store on the platform.
/// Then it was emitted as `category_id`, which `/stores/{id}/products` does not
/// validate and drops: the chip listed the whole store. It takes `category_ids`.
void main() {
  group('StoresEndpoints paths', () {
    test('store paths interpolate the id from the argument', () {
      expect(StoresEndpoints.storeDetails(7), '/api/v1/stores/7');
      expect(StoresEndpoints.storeProducts(7), '/api/v1/stores/7/products');
    });

    test('two stores get two distinct paths', () {
      // Guards the old shape coming back: the id lived in a static field, so
      // it was whatever the last caller happened to leave behind.
      expect(
        StoresEndpoints.storeProducts(7),
        isNot(StoresEndpoints.storeProducts(8)),
      );
    });

    test('featured stores hangs off the stores path', () {
      expect(StoresEndpoints.getFeaturedStores, '/api/v1/stores/featured');
    });
  });

  group('StoresEndpoints store-products query', () {
    test('carries the category id when the caller narrows to one', () {
      expect(
        StoresEndpoints.storeProductsQuery(
          page: 2,
          filter: 'all',
          categoryId: 42,
        ),
        {
          'per_page': 15,
          'page': 2,
          'filter': 'all',
          'category_ids': [42],
        },
      );
    });

    test('omits the category id for the whole-store filter tabs', () {
      expect(
        StoresEndpoints.storeProductsQuery(page: 1, filter: 'top_rated'),
        {'per_page': 15, 'page': 1, 'filter': 'top_rated'},
      );
    });

    test('carries a search term and omits an empty one', () {
      expect(
        StoresEndpoints.storeProductsQuery(
          page: 1,
          filter: 'all',
          search: 'milk',
        )['search'],
        'milk',
      );
      expect(
        StoresEndpoints.storeProductsQuery(
          page: 1,
          filter: 'all',
          search: '',
        ).containsKey('search'),
        isFalse,
      );
    });

    test('page and filter flow through independently per call', () {
      // Two filter tabs page at the same time on the store details screen;
      // with the old static fields they clobbered each other.
      final Map<String, dynamic> offers = StoresEndpoints.storeProductsQuery(
        page: 3,
        filter: 'offer',
      );
      final Map<String, dynamic> newest = StoresEndpoints.storeProductsQuery(
        page: 9,
        filter: 'new',
      );

      expect(offers['page'], 3);
      expect(offers['filter'], 'offer');
      expect(newest['page'], 9);
      expect(newest['filter'], 'new');
    });
  });

  group('StoresEndpoints stores query', () {
    test('carries page, category, rating and search', () {
      expect(
        StoresEndpoints.storesQuery(
          page: 2,
          categoryId: 5,
          rating: '4.5',
          search: 'nour',
        ),
        {
          'per_page': 15,
          'page': 2,
          'category_id': 5,
          'rating': '4.5',
          'search': 'nour',
        },
      );
    });

    test('omits every optional filter when unset', () {
      expect(StoresEndpoints.storesQuery(page: 1), {
        'per_page': 15,
        'page': 1,
      });
    });
  });
}
