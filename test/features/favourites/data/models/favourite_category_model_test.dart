import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';

void main() {
  group('FavouriteCategoryModel.fromJson', () {
    test('parses id, the name map and the count', () {
      final FavouriteCategoryModel model = FavouriteCategoryModel.fromJson({
        'id': 5,
        'name': <String, dynamic>{'en': 'Food', 'ar': 'طعام'},
        'favoritables_count': 7,
      });

      expect(model.id, 5);
      expect(model.name, <String, dynamic>{'en': 'Food', 'ar': 'طعام'});
      expect(model.favoritablesCount, 7);
    });

    test('defaults id/count to 0 and name to null when absent', () {
      final FavouriteCategoryModel model =
          FavouriteCategoryModel.fromJson(<String, dynamic>{});

      expect(model.id, 0);
      expect(model.name, isNull);
      expect(model.favoritablesCount, 0);
    });

    test('reads a numeric count coming through as a num', () {
      expect(
        FavouriteCategoryModel.fromJson({'id': 1, 'favoritables_count': 3.0})
            .favoritablesCount,
        3,
      );
    });
  });
}
