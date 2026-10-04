import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

/// Opens category details for a category the home feed or a banner names by
/// [slug] or only by [id].
///
/// Category details loads by slug, which the feed and banners now send
/// (`category_slug`). A payload without one — e.g. a feed cached before the
/// backend added it — resolves the slug from the categories already in memory
/// (the app-wide list the splash preloads and the feed's own `categories`
/// section), and does nothing when neither holds it.
// ponytail: in-memory id → slug lookup kept only for slug-less payloads; drop
// it once no cached feed predates the slugs.
void openHomeCategory(
  BuildContext context,
  WidgetRef ref, {
  int? id,
  String? slug,
  Map<String, dynamic>? name,
}) {
  final CategoryModel? known = (slug?.isNotEmpty ?? false)
      ? null
      : _loadedCategory(ref, id);
  final String? target = (slug?.isNotEmpty ?? false) ? slug : known?.slug;
  if (target == null || target.isEmpty) return;

  context.pushNamed(
    AppRoutes.categoryDetailsScreen,
    pathParameters: <String, String>{'slug': target},
    extra: name ?? known?.name,
  );
}

CategoryModel? _loadedCategory(WidgetRef ref, int? id) {
  if (id == null) return null;
  return <CategoryModel>[
        ...?ref.read(getAppCategoriesProvider).valueOrNull?.data,
        ...?ref
            .read(getHomeSectionsProvider)
            .valueOrNull
            ?.expand((HomeSectionModel section) => section.categories),
      ]
      .where((CategoryModel c) => c.id == id && (c.slug?.isNotEmpty ?? false))
      .firstOrNull;
}
