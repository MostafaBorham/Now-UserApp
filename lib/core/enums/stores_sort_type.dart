import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// Declaration order drives the tab / filter order shown to the user and
/// follows the design: All, New arrival, Most popular, Top rated.
enum StoresSortType {
  all(LangKeys.allKey),
  newArrival(LangKeys.newArrivalKey),
  mostPopular(LangKeys.mostPopularKey),
  topRated(LangKeys.topRatedKey);

  const StoresSortType(this.label);

  final String label;
}
