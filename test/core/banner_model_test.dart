import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';

void main() {
  test('productSlug reads the nested product.slug from /api/v1/banners', () {


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

    final BannerModel banner = BannerModel.fromJson(<String, dynamic>{
      'id': 2,
      'link_type': 'product',
      'product_slug': 'flat-slug',
    });

    expect(banner.productSlug, 'flat-slug');
  });
}
