import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';




enum FavouriteSortOption {
  recent(labelKey: LangKeys.recentKey, queryValue: 'recent'),
  oldest(labelKey: LangKeys.oldestKey, queryValue: 'oldest'),
  priceLowestToHighest(
    labelKey: LangKeys.priceLowestToHighestKey,
    queryValue: 'price_asc',
  ),
  priceHighestToLowest(
    labelKey: LangKeys.priceHighestToLowestKey,
    queryValue: 'price_desc',
  );

  const FavouriteSortOption({required this.labelKey, required this.queryValue});


  static const FavouriteSortOption defaultOption = FavouriteSortOption.recent;

  final String labelKey;
  final String queryValue;

  String get label => labelKey.tr();
}
