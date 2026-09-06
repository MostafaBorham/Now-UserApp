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

  test('non-offer sections carry no offers', () {
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
  });
}
