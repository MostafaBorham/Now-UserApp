import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

class SearchResultCategoriesList extends ConsumerWidget {
  const SearchResultCategoriesList({super.key, required this.searchTerm});

  final String searchTerm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final provider = searchAppCategoriesProvider(searchTerm);
    final GetAppCategoriesViewModel viewModel = ref.watch(provider.notifier);

    return LayoutBuilder(
      builder: (context, con) {
        final double imageSize = con.maxWidth * 0.144;
        final double fontSize = con.maxWidth * 0.041;

        return PaginatedView<CategoryModel>(
          key: ValueKey(searchTerm),
          provider: provider,
          onRefresh: viewModel.loadFirstPage,
          onLoadNextPage: viewModel.loadNextPage,
          enablePullToRefresh: false,
          layout: PaginatedListLayout(
            separatorBuilder: (_, _) =>
                Divider(height: 1, thickness: 1, color: colors.dividerLight),
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 16,
            ),
          ),
          firstPagePlaceholdersCount: 8,
          nextPagePlaceholdersCount: 2,
          placeholderBuilder: (_) => AppShimmer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: AppBorderRadius.brCircular8,
                    ),
                  ),
                  Container(
                    width: con.maxWidth * 0.4,
                    height: fontSize,
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: AppBorderRadius.brCircular8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          itemBuilder: (BuildContext context, CategoryModel category, int _) =>
              InkWell(
                onTap: category.slug?.isNotEmpty == true
                    ? () => context.pushNamed(
                        AppRoutes.categoryDetailsScreen,
                        pathParameters: {'slug': category.slug!},
                        extra: category.name,
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: imageSize,
                        height: imageSize,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: AppBorderRadius.brCircular8,
                        ),
                        child: AppCachedNetworkImage(
                          imageUrl: category.image ?? '',
                          width: imageSize,
                          height: imageSize,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          context.getLocalizedApiText(category.name),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.style16Bold.copyWith(
                            color: colors.neutral1200,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}
