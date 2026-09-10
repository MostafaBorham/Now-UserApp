import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

void main() {
  test('featured_offers parses offers and routes each kind to its target', () {
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 2,
      'type': 'featured_offers',
      'title': {'ar': 'عروض مميزة', 'en': 'Featured Offers'},
      'items': <Map<String, dynamic>>[
        {
          'title': 'A',
          'image_url': 'http://x/a.jpg',
          'link': {'kind': 'store', 'store': 7, 'product': null},
        },
        {
          'title': 'B',
          'image_url': 'http://x/b.jpg',
          // The shape older responses sent: a numeric product id, which
          // product details (slug-only) can't open.
          'link': {'kind': 'product', 'store': null, 'product': 42},
        },
        {
          'title': 'C',
          'image_url': null,
          'link': {'kind': 'product', 'product': 'nice-slug'},
        },
        {
          'title': 'D',
          'image_url': null,
          'link': {'kind': 'category', 'category': 'main-electronics'},
        },
      ],
    });

    expect(section.type, 'featured_offers');
    expect(section.title?['en'], 'Featured Offers');
    expect(section.title?['ar'], 'عروض مميزة');
    expect(section.offers.length, 4);

    expect(section.offers[0].kind, 'store');
    expect(section.offers[0].storeId, 7);
    expect(section.offers[0].imageUrl, 'http://x/a.jpg');

    expect(section.offers[1].kind, 'product');
    expect(section.offers[1].productSlug, isNull); // numeric id → inert

    expect(section.offers[2].productSlug, 'nice-slug'); // string slug → usable

    expect(section.offers[3].kind, 'category');
    expect(section.offers[3].categorySlug, 'main-electronics');
  });

  test('a section titled in one locale only still resolves', () {
    // The feed sends `ar` alone on some sections; `getLocalizedApiText` falls
    // back across locales, so the heading is never blank.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 45,
      'type': 'top_banner',
      'title': {'ar': 'بانرات أعلى الصفحة'},
      'items': <dynamic>[],
    });

    expect(section.title?['ar'], 'بانرات أعلى الصفحة');
    expect(section.title?['en'], isNull);
  });

  test('featured_stores parses each vendor with its inline products', () {
    // Trimmed from a real /home-sections response: vendor items use the
    // standard store keys, and their products are flattened (a bare `name`
    // string and a single `image_url`, no `product_id` / `stock`).
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 26,
      'type': 'featured_stores',
      'title': {'ar': 'المتاجر المميزة', 'en': 'Featured Stores'},
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
          // Tints this store's carousel page.
          'store_color': '#b3f5b2',
          // British spelling; the app's own key is `is_favorite`.
          'is_favourite': true,
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
    // Drives the card's tint; #RRGGBB gains a full-opacity alpha channel.
    expect(store.storeColor?.toARGB32(), 0xFFB3F5B2);
    // The British key has to reach `isFavorite` or the heart stays unfilled.
    expect(store.isFavorite, isTrue);

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

  test('nearby_stores parses each vendor with its card details', () {
    // The enriched vendor payload: same store keys as featured_stores, minus
    // the inline products (a nearby card shows the store's own details only).
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 25,
      'type': 'nearby_stores',
      'title': {'ar': 'أفضل المتاجر القريبة', 'en': 'Nearby Stores'},
      'items': <Map<String, dynamic>>[
        {
          'id': 3,
          'type': 'vendor',
          'name': {'ar': 'متجر النور', 'en': 'Al-Nour Store'},
          'logo_url': 'http://x/logo.png',
          'cover_url': 'http://x/cover.png',
          'rating': 5.0,
          'rating_count': 2,
          'delivery_fee': 12.0,
          'delivery_time': '15-25',
          'distance': 0.6,
          'is_favorite': true,
        },
      ],
    });

    expect(section.title?['ar'], 'أفضل المتاجر القريبة');
    expect(section.stores.length, 1);

    final store = section.stores.single;
    expect(store.id, 3);
    expect(store.name?['en'], 'Al-Nour Store');
    expect(store.logoUrl, 'http://x/logo.png');
    expect(store.coverUrl, 'http://x/cover.png');
    expect(store.rating, 5.0);
    expect(store.ratingCount, 2);
    expect(store.deliveryFee, 12.0);
    expect(store.deliveryTime, '15-25');
    expect(store.distance, 0.6);
    // Decides whether the card's favourite heart starts filled.
    expect(store.isFavorite, isTrue);
  });

  test('all_stores parses its vendors the same way the other store sections do',
      () {
    // Trimmed from a real /home-sections response: the section the home
    // screen's "All" tab lists, with no inline products.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 54,
      'type': 'all_stores',
      'layout': 'stores',
      'title': {'ar': 'جميع المتاجر'},
      'items': <Map<String, dynamic>>[
        {
          'id': 1,
          'type': 'vendor',
          'name': {'ar': 'متجر تجريبي API', 'en': 'API Test Vendor'},
          'logo_url': 'http://x/316.png',
          'cover_url': 'http://x/317.png',
          'rating': 0.0,
          'rating_count': 0,
          'delivery_fee': 8.0,
          'delivery_time': '25-40',
          'distance': 1.5,
          'is_favourite': false,
        },
        {
          'id': 54,
          'type': 'vendor',
          'name': {'ar': 'متجر دعم التاجر', 'en': 'Vendor Support Demo Store'},
          // A store with no artwork still has to reach the card.
          'logo_url': null,
          'cover_url': null,
          'rating': 0.0,
          'rating_count': 0,
          'delivery_fee': 15.0,
          'delivery_time': '35-50',
          'distance': 1.0,
          'is_favourite': false,
        },
      ],
    });

    expect(section.stores.map((s) => s.id).toList(), <int>[1, 54]);
    final first = section.stores.first;
    expect(first.name?['en'], 'API Test Vendor');
    expect(first.coverUrl, 'http://x/317.png');
    expect(first.deliveryTime, '25-40');
    expect(first.distance, 1.5);
    expect(first.isFavorite, isFalse);
    expect(section.stores.last.logoUrl, isNull);
    // A store section carries nothing else.
    expect(section.products, isEmpty);
    expect(section.offers, isEmpty);
    expect(section.banners, isEmpty);
  });

  test('a thin vendor item parses instead of throwing mid-feed', () {
    // The shape production still sends for nearby_stores: `name` as an
    // already-localized string and none of the detail fields. Casting that
    // string straight to a translations map threw, and because it threw while
    // parsing the feed it blanked the entire home screen — not just this store.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 192,
      'type': 'nearby_stores',
      'items': <Map<String, dynamic>>[
        {
          'id': 13389,
          'type': 'vendor',
          'name': 'opiljnlm',
          'image_url': null,
        },
      ],
    });

    final store = section.stores.single;
    expect(store.id, 13389);
    // Mirrored into both locales, so either language resolves a name.
    expect(store.name?['en'], 'opiljnlm');
    expect(store.name?['ar'], 'opiljnlm');
    // Absent details stay null, so the card leaves those rows out entirely
    // rather than rendering zeroes.
    expect(store.rating, isNull);
    expect(store.deliveryFee, isNull);
    expect(store.deliveryTime, isNull);
    expect(store.distance, isNull);
    expect(store.isFavorite, isNull);
  });

  test('a description sent as an empty array parses to null', () {
    // How a store with no description serializes — also previously a throw.
    final store = StoreModel.fromJson(<String, dynamic>{
      'id': 1,
      'name': {'ar': 'بدون', 'en': 'Nameless'},
      'description': <dynamic>[],
    });

    expect(store.id, 1);
    expect(store.description, isNull);
  });

  test('flash_offers flattens every offer wrapper into one product list', () {
    // Trimmed from a real /home-sections response: items are `home_page_offer`
    // wrappers, each holding the products the section renders one card each for.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 49,
      'type': 'flash_offers',
      'title': {'ar': 'عروض لا تفوتك', 'en': "Don't-Miss Offers"},
      'items': <Map<String, dynamic>>[
        {
          'id': 4,
          'type': 'home_page_offer',
          'products': <Map<String, dynamic>>[
            {
              'id': 52,
              'name': {'ar': 'منتج', 'en': 'product'},
              'slug': 'product',
              'price': 20.0,
              'effective_price': 13.6,
              'discount_percentage': 32.0,
              'compare_price': null,
              'rating': {'average': 4.5, 'total': 2},
              'image_url': 'http://x/p52.png',
              'vendor_logo_url': 'http://x/vendor.png',
              // Gallery entries are bare URL strings here, not attachment
              // objects — subscripting one used to throw and blank the feed.
              'images': <String>['http://x/p52.png'],
              // British spelling; the app's own key is `is_favorite`.
              'is_favourite': true,
            },
          ],
        },
        {
          'id': 3,
          'type': 'home_page_offer',
          'products': <Map<String, dynamic>>[
            {'id': 38, 'slug': 'modern-backpack', 'price': 59.5},
          ],
        },
      ],
    });

    expect(section.title?['en'], "Don't-Miss Offers");
    // Both wrappers' products, in feed order.
    expect(section.products.map((p) => p.id).toList(), <int>[52, 38]);
    expect(section.offers, isEmpty);
    expect(section.stores, isEmpty);

    final product = section.products.first;
    // The price the card shows is the deal-applied one, with the list price
    // struck through beside it.
    expect(product.effectivePrice, 13.6);
    expect(product.price, 20.0);
    expect(product.discountPercentage, 32.0);
    expect(product.rating?.average, 4.5);
    // A string gallery has to land in `images` or the card renders blank.
    expect(product.images, <String>['http://x/p52.png']);
    // Decides whether the card's favourite heart starts filled.
    expect(product.isFavorite, isTrue);
    // No nested `vendor`, so the flat logo stands in as a logo-only store.
    expect(product.vendor?.logoUrl, 'http://x/vendor.png');
    // No `product_id`, so the cart control falls back to `id`.
    expect(product.productId ?? product.id, 52);
  });

  test('promo_block_middle parses its banner item', () {
    // Verbatim from a real /home-sections response: banner items send bare URL
    // strings (not `{download_url: ...}`) and numeric ids for their link.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 50,
      'type': 'promo_block_middle',
      'layout': 'banner',
      'title': {'ar': 'بلوك ترويجي', 'en': 'Home Page Middle Banner'},
      'items': <Map<String, dynamic>>[
        {
          'slot': 'middle',
          'id': 9,
          'image_ar': 'http://x/335/download',
          'image_en': 'http://x/336/download',
          'link_type': 'product',
          'product_id': 1,
          'main_category_id': null,
          'default_url': null,
        },
      ],
    });

    expect(section.banners.length, 1);
    final banner = section.banners.first;
    expect(banner.imageAr, 'http://x/335/download');
    expect(banner.imageEn, 'http://x/336/download');
    expect(banner.linkType, 'product');
    // Numeric `product_id` isn't a slug → the tap stays inert.
    expect(banner.productSlug, isNull);
    expect(section.offers, isEmpty);
    expect(section.stores, isEmpty);
    expect(section.products, isEmpty);
  });

  test('promo_block_footer parses its banner item the same way', () {
    // The footer slot is the same item shape as the middle one, so it goes
    // through the same branch — a section type of its own is all that differs.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 53,
      'type': 'promo_block_footer',
      'layout': 'banner',
      'title': {'ar': 'بلوك ترويجي (أسفل الصفحة)'},
      'items': <Map<String, dynamic>>[
        {
          'slot': 'footer',
          'id': 2,
          'image_ar': null,
          'image_en': null,
          'link_type': 'category',
          'product_id': null,
          'main_category_id': 1,
          'default_url': null,
        },
      ],
    });

    final banner = section.banners.single;
    expect(banner.id, 2);
    expect(banner.linkType, 'category');
    // Images the admin hasn't uploaded leave the widget on its placeholder.
    expect(banner.imageAr, isNull);
    expect(banner.imageEn, isNull);
    // Numeric `main_category_id` isn't a slug → the tap stays inert.
    expect(banner.categorySlug, isNull);
  });

  test('products_by_category parses its products, category and theming', () {
    // Trimmed from a real /home-sections response. Items are the products
    // themselves (no offer wrapper, unlike flash_offers), and the section
    // carries its own header theming.
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 51,
      'type': 'products_by_category',
      // The admin's generic label — the same on every section of this type,
      // so the heading shown is `category_name` instead.
      'title': {'ar': 'منتجات حسب الفئة'},
      'show_view_all': true,
      'primary_color': '#027e54',
      'display_design': 'color_with_image',
      'media': 'http://x/media.png',
      'media_ar': 'http://x/media_ar.png',
      'media_en': 'http://x/media_en.png',
      'category_id': 1,
      'category_name': {'ar': 'إلكترونيات', 'en': 'Electronics'},
      'items': <Map<String, dynamic>>[
        {
          'id': 54,
          'type': 'product',
          'name': {'ar': 'كمبيوتر', 'en': 'Computer'},
          'slug': 'computer',
          'price': 20.0,
          'effective_price': 13.6,
          'deal_discount_amount': 6.4,
          'discount_percentage': 32.0,
          'rating': {'average': 0.0, 'total': 0},
          'image_url': 'http://x/p54.png',
          'vendor_logo_url': 'http://x/vendor.png',
          'is_favourite': false,
        },
        {'id': 52, 'slug': 'product', 'price': 20.0},
      ],
    });

    expect(section.products.map((p) => p.id).toList(), <int>[54, 52]);
    expect(section.category?.id, 1);
    expect(section.category?.name?['en'], 'Electronics');
    // The heading is the category, never the section's own generic title.
    expect(section.category?.name?['ar'], 'إلكترونيات');
    expect(section.showViewAll, isTrue);
    expect(section.displayDesign, 'color_with_image');
    // #RRGGBB gains a full-opacity alpha channel.
    expect(section.primaryColor?.toARGB32(), 0xFF027E54);
    // Absent from this section → the widget falls back to a theme colour.
    expect(section.textColor, isNull);
    expect(section.media?['ar'], 'http://x/media_ar.png');
    expect(section.media?['en'], 'http://x/media_en.png');
    // Flat product keys still have to reach the card.
    expect(section.products.first.images, <String>['http://x/p54.png']);
    expect(section.products.first.vendor?.logoUrl, 'http://x/vendor.png');
    // Not a flash_offers wrapper, so nothing else is populated.
    expect(section.offers, isEmpty);
    expect(section.stores, isEmpty);
    expect(section.banners, isEmpty);
  });

  test('a color_only products_by_category section carries no media', () {
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 52,
      'type': 'products_by_category',
      'show_view_all': false,
      'primary_color': '#8B5CF6',
      'text_color': '#000000',
      'display_design': 'color_only',
      'media': null,
      'media_ar': null,
      'media_en': null,
      'category_id': 4,
      'category_name': {'ar': 'المنزل والمطبخ', 'en': 'Home & Kitchen'},
      'items': <Map<String, dynamic>>[
        {'id': 53, 'slug': 'darius-weeks-edited', 'price': 100.0},
      ],
    });

    expect(section.displayDesign, 'color_only');
    expect(section.primaryColor?.toARGB32(), 0xFF8B5CF6);
    expect(section.textColor?.toARGB32(), 0xFF000000);
    // Null media leaves the header title-only instead of a broken image slot.
    expect(section.media, isNull);
    expect(section.showViewAll, isFalse);
    expect(section.products.single.id, 53);
  });

  test('a malformed primary_color falls back to null, not a crash', () {
    final HomeSectionModel section = HomeSectionModel.fromJson(<String, dynamic>{
      'id': 53,
      'type': 'products_by_category',
      'primary_color': 'not-a-color',
      'text_color': '#fff',
      'items': <Map<String, dynamic>>[],
    });

    expect(section.primaryColor, isNull);
    // Three-digit shorthand isn't a shape the backend sends — rejected rather
    // than parsed into the wrong colour.
    expect(section.textColor, isNull);
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
