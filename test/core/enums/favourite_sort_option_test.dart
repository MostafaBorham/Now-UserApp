import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_sort_option.dart';

void main() {
  group('FavouriteSortOption', () {
    test('query values match the backend sort contract', () {
      expect(FavouriteSortOption.recent.queryValue, 'recent');
      expect(FavouriteSortOption.oldest.queryValue, 'oldest');
      expect(FavouriteSortOption.priceLowestToHighest.queryValue, 'price_asc');
      expect(FavouriteSortOption.priceHighestToLowest.queryValue, 'price_desc');
    });

    test('every option is within the accepted set (so none silently resets)',
        () {
      const Set<String> accepted = <String>{
        'recent',
        'oldest',
        'price_asc',
        'price_desc',
      };
      for (final FavouriteSortOption option in FavouriteSortOption.values) {
        expect(accepted.contains(option.queryValue), isTrue, reason: option.name);
      }
    });

    test('the default is recent (matches the API default)', () {
      expect(FavouriteSortOption.defaultOption, FavouriteSortOption.recent);
    });
  });
}
