import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/top_brands/top_brands_item.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';

class TopBrandsView extends ConsumerWidget {
  const TopBrandsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GetFeaturedStoresViewModel viewModel =
        ref.read(getFeaturedStoresProvider.notifier);

    return PaginatedView<StoreModel>(
      provider: getFeaturedStoresProvider,
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      firstPagePlaceholdersCount: 8,
      layout: const PaginatedGridLayout(
        padding: EdgeInsets.all(5),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 167 / 164,
        ),
      ),
      placeholderBuilder: (_) => const AppShimmer(child: TopBrandsItem()),
      emptyBuilder: (BuildContext context) => NoResultsWidget(
        isScrollable: true,
        emptyMessage: LangKeys.noStoresYetKey.tr(),
      ),
      itemBuilder: (context, StoreModel store, index) => InkWell(
        onTap: store.id == null
            ? null
            : () => context.pushNamed(
                  AppRoutes.storeDetailsScreen,
                  pathParameters: <String, String>{'id': '${store.id}'},
                  extra: store.name,
                ),
        child: TopBrandsItem(store: store),
      ),
    );
  }
}
