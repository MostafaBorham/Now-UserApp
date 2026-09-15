import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';



enum SeparateOption {
  topRated(labelKey: LangKeys.topRatedKey, queryValue: 'top_rated'),
  mostPopularProduct(
    labelKey: LangKeys.mostPopularProductKey,
    queryValue: 'most_popular',
  ),
  priceHighestToLowest(
    labelKey: LangKeys.priceHighestToLowestKey,
    queryValue: 'price_desc',
  ),
  priceLowestToHighest(
    labelKey: LangKeys.priceLowestToHighestKey,
    queryValue: 'price_asc',
  );

  const SeparateOption({required this.labelKey, required this.queryValue});

  final String labelKey;
  final String queryValue;

  String get label => labelKey.tr();
}
