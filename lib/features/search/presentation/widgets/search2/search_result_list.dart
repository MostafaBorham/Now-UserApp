import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/products/product_details_list_scope.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/pagination_scroll_listener.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';
import 'package:nowdelivery_user_app/features/search/data/last_search_results_cache.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_results_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_all_stores_vm.dart';

class SearchResultList extends ConsumerWidget {
  const SearchResultList({super.key, required this.searchTerm});

  final String searchTerm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsProvider = getProductsProvider(searchTerm);
    final storesProvider = getAllStoresProvider(
      SearchResultsView.storesArgsOf(searchTerm),
    );
    final products = PaginationStatus.from(ref.watch(productsProvider));
    final stores = PaginationStatus.from(ref.watch(storesProvider));
    final productsVm = ref.read(productsProvider.notifier);
    final storesVm = ref.read(storesProvider.notifier);

    Future<void> refresh() =>
        Future.wait([productsVm.loadFirstPage(), storesVm.loadFirstPage()]);

    final int resultCount = products.items.length + stores.items.length;
    final bool firstPageLoading =
        products.isFirstPageLoading || stores.isFirstPageLoading;
    if (resultCount == 0 && !firstPageLoading) {
      final String? error = products.firstPageError ?? stores.firstPageError;
      return AppRefreshIndicator(
        onRefresh: refresh,
        child: error == null
            ? NoResultsWidget(
                isScrollable: true,
                emptyMessage: LangKeys.noResultsKey.tr(),
              )
            : ServerConnectionErrorWidget(
                isScrollable: true,
                message: error,
                onRetry: refresh,
              ),
      );
    }

    final int placeholders = firstPageLoading && resultCount == 0
        ? 8
        : firstPageLoading ||
              products.isNextPageLoading ||
              stores.isNextPageLoading
        ? 2
        : 0;
    return ProductDetailsListScope(
      productSlugs: () =>
          ref
              .read(productsProvider)
              .valueOrNull
              ?.data
              .map((product) => product.slug) ??
          const <String>[],
      child: AppRefreshIndicator(
        onRefresh: refresh,
        child: PaginationScrollListener(
          canLoadNextPage:
              products.canRequestNextPage || stores.canRequestNextPage,
          onLoadNextPage: () {
            if (products.canRequestNextPage) productsVm.loadNextPage();
            if (stores.canRequestNextPage) storesVm.loadNextPage();
          },
          child: LayoutBuilder(
            builder: (context, constraints) => ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 16,
              ),
              itemCount: resultCount + placeholders,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: context.colors.dividerLight,
              ),
              itemBuilder: (context, index) {
                final double width = constraints.maxWidth;
                if (index >= resultCount) {
                  return AppShimmer(
                    child: _ResultRow(width: width, isPlaceholder: true),
                  );
                }
                if (index < products.items.length) {
                  final ProductModel product = products.items[index];
                  final slug = product.slug;
                  return _ResultRow(
                    width: width,
                    name: context.getLocalizedApiText(product.name),
                    imageUrl: product.images?.firstOrNull ?? '',
                    onTap: slug == null || slug.isEmpty
                        ? null
                        : () {
                            unawaited(
                              ref
                                  .read(lastSearchResultsCacheProvider)
                                  .saveProduct(product),
                            );
                            ProductDetailsListScope.open(context, slug);
                          },
                  );
                }
                final StoreModel store =
                    stores.items[index - products.items.length];
                return _ResultRow(
                  width: width,
                  name: context.getLocalizedApiText(store.name),
                  imageUrl: store.logoUrl ?? '',
                  onTap: store.id == null
                      ? null
                      : () {
                          unawaited(
                            ref
                                .read(lastSearchResultsCacheProvider)
                                .saveStore(store),
                          );
                          context.pushNamed(
                            AppRoutes.storeDetailsScreen,
                            pathParameters: {'id': '${store.id}'},
                            extra: store.name,
                          );
                        },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.width,
    this.name = '',
    this.imageUrl = '',
    this.onTap,
    this.isPlaceholder = false,
  });

  final double width;
  final String name;
  final String imageUrl;
  final VoidCallback? onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double imageSize = width * 0.144;
    final double fontSize = width * 0.041;
    return InkWell(
      onTap: onTap,
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
                color: isPlaceholder ? colors.white : null,
                gradient: isPlaceholder
                    ? null
                    : LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [colors.neutral200, colors.white],
                      ),
                borderRadius: AppBorderRadius.brCircular8,
              ),
              child: isPlaceholder
                  ? null
                  : AppCachedNetworkImage(
                      imageUrl: imageUrl,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBackgroundColor: Colors.transparent,
                    ),
            ),
            if (isPlaceholder)
              Container(
                width: width * 0.4,
                height: fontSize,
                decoration: BoxDecoration(
                  color: colors.white,
                  borderRadius: AppBorderRadius.brCircular8,
                ),
              )
            else
              Expanded(
                child: Text(
                  name,
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
    );
  }
}
