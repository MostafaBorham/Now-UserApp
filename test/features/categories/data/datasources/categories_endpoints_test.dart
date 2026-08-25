import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_endpoints.dart';

void main() {
  group('CategoriesEndpoints paths', () {
    test('app categories path is the tree endpoint', () {
      expect(CategoriesEndpoints.getAppCategories, '/api/v1/categories/tree');
    });

    test('store / product paths interpolate the slug from the argument', () {
      expect(
        CategoriesEndpoints.categoryStores('electronics'),
        '/api/v1/categories/electronics/stores',
      );
      expect(
        CategoriesEndpoints.categoryProducts('electronics'),
        '/api/v1/categories/electronics/products',
      );
    });
  });

  group('CategoriesEndpoints queries', () {
    test('app categories query carries max_depth, per_page and the page arg', () {
      expect(CategoriesEndpoints.appCategoriesQuery(3), {
        'max_depth': 1,
        'per_page': 100,
        'page': 3,
      });
    });

    test('stores query forwards page and category_id', () {
      expect(
        CategoriesEndpoints.categoryStoresQuery(page: 2, categoryId: 7),
        {'per_page': 15, 'page': 2, 'category_id': 7},
      );
    });

    test('stores query keeps a null category_id (no crash, matches old shape)',
        () {
      expect(CategoriesEndpoints.categoryStoresQuery(page: 1), {
        'per_page': 15,
        'page': 1,
        'category_id': null,
      });
    });

    test('products query pins the price ascending sort', () {
      expect(CategoriesEndpoints.categoryProductsQuery(page: 5), {
        'per_page': 15,
        'page': 5,
        'sort': 'price',
        'direction': 'asc',
        'category_id': null,
      });
    });

    test('page argument flows through independently per call', () {
      // Guards the old bug: paging state is no longer shared/static, so two
      // different page requests do not clobber each other.
      final storesPage2 = CategoriesEndpoints.categoryStoresQuery(page: 2);
      final productsPage9 = CategoriesEndpoints.categoryProductsQuery(page: 9);
      expect(storesPage2['page'], 2);
      expect(productsPage9['page'], 9);
    });
  });
}
