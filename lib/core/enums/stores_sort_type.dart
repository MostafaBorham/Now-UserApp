import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';



enum StoresSortType {
  all(LangKeys.allKey),
  newArrival(LangKeys.newArrivalKey),
  mostPopular(LangKeys.mostPopularKey),
  topRated(LangKeys.topRatedKey);

  const StoresSortType(this.label);

  final String label;
}
