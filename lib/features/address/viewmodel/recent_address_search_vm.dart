import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/repo/recent_keywords_repo.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';

/// The recent keywords of the address search screen.
///
/// The address twin of `recentSearchProvider` — same behaviour, its own Hive
/// box, so an area the user searched for never surfaces as a product keyword.
/// Loads as soon as the provider is first watched.
///
/// The cap is deliberately lower than the product search's: the address recents
/// are laid out under the search field with no scroll view of their own, so a
/// long list would squeeze the results area.
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
