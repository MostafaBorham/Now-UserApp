import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

enum StoresSortType {
  all(LangKeys.allKey),
  topRated(LangKeys.topRatedKey),
  mostPopular(LangKeys.mostPopularKey),
  newArrival(LangKeys.newArrivalKey);

  const StoresSortType(this.label);

  final String label;
}
