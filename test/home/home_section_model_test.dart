import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

void main() {
  test('featured_offers parses offers and routes each kind to its target', () {
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 2,
      'type': 'featured_offers',
      'title': 'Special',
      'items': <Map<String, dynamic>>[
        {
          'title': 'A',
          'image_url': 'http://x/a.jpg',
          'link': {'kind': 'store', 'store': 7, 'product': null},
        },
        {
          'title': 'B',
          'image_url': 'http://x/b.jpg',
          // Backend sends a numeric product id today → not navigable by slug.
          'link': {'kind': 'product', 'store': null, 'product': 42},
        },
        {
          'title': 'C',
          'image_url': null,
          // Once the backend emits a real slug, product taps work unchanged.
          'link': {'kind': 'product', 'product': 'nice-slug'},
        },
      ],
    });

    expect(section.type, 'featured_offers');
    expect(section.title, 'Special');
    expect(section.offers.length, 3);

    expect(section.offers[0].kind, 'store');
    expect(section.offers[0].storeId, 7);
    expect(section.offers[0].imageUrl, 'http://x/a.jpg');

    expect(section.offers[1].kind, 'product');
    expect(section.offers[1].productSlug, isNull); // numeric id → inert

    expect(section.offers[2].productSlug, 'nice-slug'); // string slug → usable
  });

  test('featured_stores parses each vendor with its inline products', () {
    // Trimmed from a real /home-sections response: vendor items use the
    // standard store keys, and their products are flattened (a bare `name`
    // string and a single `image_url`, no `product_id` / `stock`).
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 26,
      'type': 'featured_stores',
      'title': 'المتاجر المميزة',
      'items': <Map<String, dynamic>>[
        {
          'id': 3,
          'type': 'vendor',
          'name': {'ar': 'متجر النور', 'en': 'Al-Nour Store'},
          'logo_url': 'http://x/logo.png',
          'rating': 0.0,
          'rating_count': 0,
          'delivery_fee': 12.0,
          'delivery_time': '15-25',
          'distance': 2.5,
          'products': <Map<String, dynamic>>[
            {
              'id': 51,
              'type': 'product',
              'name': 'Medium Roast Ground Coffee',
              'slug': 'sf-tree-medium-roast-ground-coffee',
              'price': 62.0,
              'effective_price': 42.15,
              'deal_discount_amount': 19.85,
              'discount_percentage': 32.02,
              'rating': {'average': 2.0, 'total': 2},
              'image_url': 'http://x/coffee.png',
            },
          ],
        },
      ],
    });

    expect(section.stores.length, 1);
    final store = section.stores.single;
    expect(store.id, 3);
    expect(store.name?['en'], 'Al-Nour Store');
    expect(store.deliveryFee, 12.0);
    expect(store.deliveryTime, '15-25');
    expect(store.distance, 2.5);

    final product = store.products!.single;
    // A bare name string is mirrored into both locales.
    expect(product.name?['en'], 'Medium Roast Ground Coffee');
    expect(product.name?['ar'], 'Medium Roast Ground Coffee');
    // The flat `image_url` has to land in `images` or the tile renders blank.
    expect(product.images, <String>['http://x/coffee.png']);
    // The price the tile shows is the deal-applied one, not the discount amount.
    expect(product.effectivePrice, 42.15);
    expect(product.discountPercentage, 32.02);
    expect(product.rating?.average, 2.0);
    expect(product.rating?.total, 2);
    // No `product_id`, so the cart control falls back to `id`.
    expect(product.productId, isNull);
    expect(product.productId ?? product.id, 51);
    expect(product.slug, 'sf-tree-medium-roast-ground-coffee');
  });

  test('non-offer sections carry no offers and no stores', () {
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 1,
      'type': 'categories',
      'title': 'Categories',
      'items': <Map<String, dynamic>>[
        {'id': 5, 'type': 'category', 'name': 'Electronics'},
      ],
    });

    expect(section.type, 'categories');
    expect(section.offers, isEmpty);
    expect(section.stores, isEmpty);
  });
}
