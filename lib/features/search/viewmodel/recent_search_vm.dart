import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/repo/recent_keywords_repo.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';

/// The user's recent product-search keywords.
///
/// Loads as soon as the provider is first watched, so screens only need to
/// `ref.watch(recentSearchProvider)` and render the [AsyncValue].
final recentSearchProvider =
    StateNotifierProvider.autoDispose<
      RecentKeywordsViewModel,
      AsyncValue<List<String>>
    >(
      (Ref ref) => RecentKeywordsViewModel(
        RecentKeywordsRepo(
          boxName: HiveBoxes.recentSearches,
          key: HiveKeys.recentSearchKeywords,
          maxKeywords: 10,
        ),
      )..getRecentSearches(),
    );
