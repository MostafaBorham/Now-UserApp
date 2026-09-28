import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';

void main() {
  test('productSlug reads the nested product.slug from /api/v1/banners', () {
    // Shape emitted by BannerResource (public banners endpoint): product slug
    // is nested, categories carry ids only (no slug).
    final BannerModel banner = BannerModel.fromJson(<String, dynamic>{
      'id': 1,
      'link_type': 'product',
      'product': {'id': 9, 'name': 'X', 'slug': 'cool-thing'},
      'image_en': {'download_url': 'http://x/en.jpg'},
    });

    expect(banner.productSlug, 'cool-thing');
    expect(banner.imageEn, 'http://x/en.jpg');
  });

  test('productSlug still reads the flat product_slug from store banners', () {
    // Shape emitted by PublicStoreResource (embedded store banners): flat slug.
    final BannerModel banner = BannerModel.fromJson(<String, dynamic>{
      'id': 2,
      'link_type': 'product',
      'product_slug': 'flat-slug',
    });

    expect(banner.productSlug, 'flat-slug');
  });

  test('mainCategoryId reads the nested categories map from /api/v1/banners', () {
    final BannerModel banner = BannerModel.fromJson(<String, dynamic>{
      'id': 1817,
      'link_type': 'category',
      'categories': {
        'main_category_id': 1,
        'sub_category_1_id': 2,
        'main_category': {'id': 1, 'name': 'Electronics'},
      },
    });

    expect(banner.mainCategoryId, 1);
  });

  test('mainCategoryId reads the flat main_category_id from home-sections', () {
    final BannerModel banner = BannerModel.fromJson(<String, dynamic>{
      'slot': 'top',
      'id': 1817,
      'link_type': 'category',
      'product_id': null,
      'main_category_id': 1,
    });

    expect(banner.mainCategoryId, 1);
    expect(BannerModel.fromJson(banner.toJson()).mainCategoryId, 1);
  });
}
