import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

enum ProductFilters {
  all(labelKey: LangKeys.allKey, queryValue: 'all'),
  offer(labelKey: LangKeys.offersKey, queryValue: 'offer'),
  topRated(labelKey: LangKeys.topRatedKey, queryValue: 'top_rated'),
  mostRequested(
    labelKey: LangKeys.mostRequestedKey,
    queryValue: 'most_requested',
  ),
  newest(labelKey: LangKeys.newArrivalKey, queryValue: 'new');

  const ProductFilters({required this.labelKey, required this.queryValue});

  static const ProductFilters defaultFilter = ProductFilters.all;

  final String labelKey;
  final String queryValue;

  String get label => labelKey.tr();
}
