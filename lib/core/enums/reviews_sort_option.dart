import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

enum ReviewsSortOption {
  latest(labelKey: LangKeys.latestKey),
  ratingsHighestFirst(labelKey: LangKeys.ratingsHighestFirstKey),
  ratingsLowestFirst(labelKey: LangKeys.ratingsLowestFirstKey);

  const ReviewsSortOption({required this.labelKey});

  final String labelKey;

  String get label => labelKey.tr();
}
