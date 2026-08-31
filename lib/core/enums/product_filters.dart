import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// The product filters a store's products endpoint understands. Each value
/// carries its display label key and the `filter` query value sent to the API
/// (`filter=top_rated`, …).
///
/// Declaration order drives the tab / filter order shown to the user in the
/// store details screen. [all] is the default the store details screen opens
/// on, so its products load first.
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

  /// The filter the store details screen opens on.
  static const ProductFilters defaultFilter = ProductFilters.all;

  final String labelKey;
  final String queryValue;

  String get label => labelKey.tr();
}
