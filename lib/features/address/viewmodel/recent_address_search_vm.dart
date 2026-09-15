import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/repo/recent_keywords_repo.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';










final recentAddressSearchProvider =
    StateNotifierProvider.autoDispose<
      RecentKeywordsViewModel,
      AsyncValue<List<String>>
    >(
      (Ref ref) => RecentKeywordsViewModel(
        RecentKeywordsRepo(
          boxName: HiveBoxes.recentAddressSearches,
          key: HiveKeys.recentAddressSearchKeywords,
          maxKeywords: 5,
        ),
      )..getRecentSearches(),
    );
