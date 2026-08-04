import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';

void main() {
  group('BannerModel', () {
    test('null json returns an all-null model', () {
      expect(BannerModel.fromJson(null).id, isNull);
    });

    test('image is read from the nested download_url', () {
      final model = BannerModel.fromJson({
        'id': 1,
        'image': {'download_url': 'banner.png'},
      });
      expect(model.image, 'banner.png');
    });

    test('missing image is null', () {
      expect(BannerModel.fromJson({'id': 1}).image, isNull);
    });
  });

  group('CouponModel', () {
    test('isPercentage is derived from discount_type', () {
      expect(
        CouponModel.fromJson({'discount_type': 'percentage'}).isPercentage,
        isTrue,
      );
      expect(
        CouponModel.fromJson({'discount_type': 'fixed'}).isPercentage,
        isFalse,
      );
    });

    test('toJson maps isPercentage back to a discount_type string', () {
      expect(
        const CouponModel(isPercentage: false).toJson()['discount_type'],
        'fixed',
      );
      expect(
        const CouponModel(isPercentage: true).toJson()['discount_type'],
        'percentage',
      );
    });

    test('numeric amounts coerce to double', () {
      final model = CouponModel.fromJson({
        'discount_value': 10,
        'min_order_value': 50,
      });
      expect(model.discountValue, 10.0);
      expect(model.minOrderValue, 50.0);
    });
  });

  group('ActiveDealModel', () {
    test('ISO date strings are parsed into DateTime', () {
      final model = ActiveDealModel.fromJson({
        'id': 1,
        'starts_at': '2026-01-01T00:00:00.000Z',
        'ends_at': null,
      });
      expect(model.startsAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(model.endsAt, isNull);
    });

    test('equality is value-based (Equatable)', () {
      expect(
        const ActiveDealModel(id: 1, name: 'x'),
        const ActiveDealModel(id: 1, name: 'x'),
      );
      expect(
        const ActiveDealModel(id: 1, name: 'x'),
        isNot(const ActiveDealModel(id: 2, name: 'x')),
      );
    });
  });
}
