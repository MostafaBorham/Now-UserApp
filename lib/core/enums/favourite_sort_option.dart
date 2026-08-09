import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Sort orders the favourites list endpoint understands. Each value carries its
/// display label key and the `sort` query value sent to the API. Price sorts
/// only order products; favourited stores have no price and sink to the end.
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

  /// The default the API also falls back to when `sort` is absent.
  static const FavouriteSortOption defaultOption = FavouriteSortOption.recent;

  final String labelKey;
  final String queryValue;

  String get label => labelKey.tr();
}
