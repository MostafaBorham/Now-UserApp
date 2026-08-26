import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/copy_to_clipboard.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_coupons_vm.dart';

import '../widgets/discount_code/discount_card.dart';
import '../widgets/discount_code/discount_card_shimmer.dart';
import '../widgets/discount_code/discount_coupons_shimmer_view.dart';

class DiscountCodeScreen extends ConsumerStatefulWidget {
  const DiscountCodeScreen({super.key});

  @override
  ConsumerState<DiscountCodeScreen> createState() => _DiscountCodeScreenState();
}

class _DiscountCodeScreenState extends ConsumerState<DiscountCodeScreen> {
  final ScrollController _scrollController = ScrollController();
  late final GetCouponsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    viewModel = ref.read(getCouponsProvider.notifier);
    viewModel.loadMoreState.addListener(_onLoadMoreStateChanged);
    // Load the coupons the first time this screen opens, or retry if a previous
    // open failed; an already-loaded list is kept as-is (no refetch).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(getCouponsProvider).hasValue) {
        viewModel.getCoupons();
      }
    });
  }

  @override
  void dispose() {
    viewModel.loadMoreState.removeListener(_onLoadMoreStateChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    // Leaving on a failed load: drop the kept-alive provider from the outside so
    // the next open starts fresh in `loading` and refetches, instead of
    // reopening onto the stale error. Doing it here (not while watching) avoids
    // recreating the provider under a live listener, so there is no permanent
    // shimmer and no refetch loop.
    if (ref.read(getCouponsProvider).hasError) {
      ref.invalidate(getCouponsProvider);
    }
    super.dispose();
  }

  /// Surfaces a load-more failure as an error snackbar, so a paging error is
  /// shown without replacing the already-visible list with a full-screen error.
  void _onLoadMoreStateChanged() {
    final AsyncValue<bool> loadMoreState = viewModel.loadMoreState.value;
    if (loadMoreState.hasError && mounted) {
      ErrorSnackBar.show(context, loadMoreState.error.toString());
    }
  }

  void _onScroll() {
    // Only load more once the very end of the list is fully visible on screen.
    // `extentAfter` is the amount of scrollable content still hidden below the
    // viewport, so it reaches 0 exactly when no part of the list tail is
    // clipped off-screen.
    if (_scrollController.position.extentAfter <= 0) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginationModel<CouponModel>> couponsState = ref.watch(
      getCouponsProvider,
    );

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.discountCodes.tr(),
        body: couponsState.when(
          loading: () => const DiscountCouponsShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: viewModel.getCoupons,
              ),
          data: (PaginationModel<CouponModel> page) {
            final List<CouponModel> coupons = page.data;

            return AppRefreshIndicator(
              onRefresh: viewModel.getCoupons,
              child: coupons.isEmpty
                  ? NoResultsWidget(
                      isScrollable: true,
                      emptyMessage: LangKeys.noItemsYetKey.tr(),
                    )
                  : ValueListenableBuilder<AsyncValue<bool>>(
                      valueListenable: viewModel.loadMoreState,
                      builder:
                          (
                            BuildContext context,
                            AsyncValue<bool> value,
                            Widget? child,
                          ) {
                            final int loadingItemsCount = value.isLoading
                                ? 3
                                : 0;
                            return ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: coupons.length + loadingItemsCount,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(height: 16),
                              itemBuilder: (BuildContext context, int index) {
                                if (index >= coupons.length) {
                                  return const DiscountCardShimmer();
                                }
                                final CouponModel coupon = coupons[index];
                                return DiscountCard(
                                  coupon: coupon,
                                  dark: index.isOdd,
                                  onCopy: () =>
                                      CopyToClipboard.copy(context, coupon.code ?? ''),
                                );
                              },
                            );
                          },
                    ),
            );
          },
        ),
      ),
    );
  }
}
