import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';

import 'home_view_all_widget.dart';

class HomeMostPopularBrandsView extends ConsumerWidget {
  const HomeMostPopularBrandsView({super.key});

  static const int _brandsCount = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<StoreModel>> state = ref.watch(
      getFeaturedStoresProvider,
    );

    // Nothing featured → hide the whole section (header included).
    if (state.hasValue && state.value!.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, con) {
        final double cardWidth = con.maxWidth * 0.42;
        final double logoSize = con.maxWidth * 0.13;
        final double cardHeight = logoSize + 24;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    LangKeys.topBrandsKey.tr(),
                    style: TextStyle(
                      fontSize: con.maxWidth * 0.05,
                      color: colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  HomeViewAllWidget(
                    size: con.maxWidth * 0.035,
                    startBackgroundColor: colors.amber500.withValues(
                      alpha: 0.4,
                    ),
                    onTap: () => context.pushNamed(AppRoutes.topBrandsScreen),
                  ),
                ],
              ),
              _brandsArea(
                context: context,
                ref: ref,
                state: state,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
              ),
            ],
          ),
        );
      },
    );
  }

  /// The grid area under the header. Data wins whenever a page is loaded — it
  /// stays put while the shared provider fetches a further page for the
  /// top-brands screen, instead of the carousel flickering back to a shimmer.
  Widget _brandsArea({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<PaginationModel<StoreModel>> state,
    required double cardWidth,
    required double cardHeight,
  }) {
    if (state.hasValue) {
      final List<StoreModel> visible = state.value!.data
          .take(_brandsCount)
          .toList();
      return _BrandsGrid(
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final StoreModel store = visible[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: store.id == null
                ? null
                : () => context.pushNamed(
                    AppRoutes.storeDetailsScreen,
                    pathParameters: <String, String>{'id': '${store.id}'},
                    extra: store.name,
                  ),
            child: _BrandCard(
              width: cardWidth,
              height: cardHeight,
              store: store,
            ),
          );
        },
      );
    }

    if (state.hasError) {
      return ServerConnectionErrorWidget(
        message: state.error is String ? state.error as String : null,
        onRetry: () =>
            ref.read(getFeaturedStoresProvider.notifier).loadFirstPage(),
      );
    }

    return _BrandsGrid(
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      itemCount: _brandsCount,
      itemBuilder: (context, index) => AppShimmer(
        child: _BrandCard(width: cardWidth, height: cardHeight),
      ),
    );
  }
}

class _BrandsGrid extends StatelessWidget {
  const _BrandsGrid({
    required this.cardWidth,
    required this.cardHeight,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double cardWidth;
  final double cardHeight;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight * 2 + 12,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: cardWidth,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.width, required this.height, this.store});

  final double width;
  final double height;

  /// Null in the loading (shimmer) state — the card then paints neutral
  /// placeholder blocks for AppShimmer to run over.
  final StoreModel? store;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final StoreModel? store = this.store;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.neutral500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8,
        children: [
          AspectRatio(aspectRatio: 1, child: _logo(context, colors, store)),
          Expanded(
            child: store == null
                ? _placeholder(colors, height: 12)
                : Text(
                    context.getLocalizedApiText(store.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: width * 0.1,
                      color: colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _logo(BuildContext context, AppColorScheme colors, StoreModel? store) {
    if (store == null) return _placeholder(colors);
    // No approved logo → the "failed to load image" placeholder, not a blank.
    return AppCachedNetworkImage(
      imageUrl: store.logoUrl ?? '',
      fit: BoxFit.contain,
    );
  }

  Widget _placeholder(AppColorScheme colors, {double? height}) => Container(
    height: height,
    decoration: BoxDecoration(
      color: colors.neutral500,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
