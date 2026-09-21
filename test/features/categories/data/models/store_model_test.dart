import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

void main() {
  group('StoreModel.fromJson', () {
    test('null json returns an all-null model', () {
      final model = StoreModel.fromJson(null);
      expect(model.id, isNull);
      expect(model.categories, isNull);
    });

    test('name is kept as the raw translation map (not mirrored)', () {
      final model = StoreModel.fromJson({
        'name': {'en': 'Shop', 'ar': 'متجر'},
      });
      expect(model.name, {'en': 'Shop', 'ar': 'متجر'});
    });

    test('numeric fields coerce to the right types', () {
      final model = StoreModel.fromJson({
        'id': 4,
        'rating': 4.5,
        'rating_count': 20,
        'delivery_fee': 3,
      });
      expect(model.id, 4);
      expect(model.rating, 4.5);
      expect(model.ratingCount, 20);
      expect(model.deliveryFee, 3.0);
    });

    test('nested category / coupon / banner lists are parsed', () {
      final model = StoreModel.fromJson({
        'categories': [
          {'slug': 'a'},
        ],
        'coupons': [
          {'code': 'SAVE10', 'discount_type': 'percentage'},
        ],
        'banners': [
          {
            'id': 1,
            'image': {'download_url': 'b.png'},
          },
        ],
      });
      expect(model.categories, hasLength(1));
      expect(model.categories!.first.slug, 'a');
      expect(model.coupons!.first.code, 'SAVE10');
      expect(model.banners!.first.image, 'b.png');
    });

    test('single leading offer (with nested products) is parsed', () {
      // The storefront now returns one leading `offer` object (or null), not an
      // `offers` list — see PublicStoreResource + StoreModel.offer.
      final model = StoreModel.fromJson({
        'offer': {
          'id': 303,
          'name': 'Store Offer',
          'discount_type': 'percentage',
          'discount_value': 10.0,
          'scope': 'products',
          'products_count': 1,
          'products': [
            {
              'id': 94,
              'name': {'en': 'Perfume', 'ar': 'عطر'},
            },
          ],
        },
      });
      final offer = model.offer;
      expect(offer, isNotNull);
      expect(offer!.id, 303);
      expect(offer.name, 'Store Offer');
      expect(offer.discountType, 'percentage');
      expect(offer.discountValue, 10.0);
      expect(offer.productsCount, 1);
      expect(offer.products, hasLength(1));
      expect(offer.products!.first.id, 94);
    });

    test('offer is null when the storefront omits it', () {
      expect(StoreModel.fromJson({'id': 1}).offer, isNull);
    });
  });

  group('StoreModel.copyWith', () {
    test('overrides only the given field', () {
      const original = StoreModel(id: 1, rating: 3.0, isOpen: true);
      final updated = original.copyWith(rating: 4.0);
      expect(updated.rating, 4.0);
      expect(updated.id, 1);
      expect(updated.isOpen, true);
    });
  });
}
