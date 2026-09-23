import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/copy_to_clipboard.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_coupons_vm.dart';

import '../widgets/discount_code/discount_card.dart';
import '../widgets/discount_code/discount_card_shimmer.dart';

class DiscountCodeScreen extends ConsumerStatefulWidget {
  const DiscountCodeScreen({super.key});

  @override
  ConsumerState<DiscountCodeScreen> createState() => _DiscountCodeScreenState();
}

class _DiscountCodeScreenState extends ConsumerState<DiscountCodeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GetCouponsViewModel viewModel = ref.read(getCouponsProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.discountCodes.tr(),
        scrollController: _scrollController,
        body: PaginatedView<CouponModel>(
          provider: getCouponsProvider,
          scrollController: _scrollController,
          onRefresh: viewModel.loadFirstPage,
          onLoadNextPage: viewModel.loadNextPage,
          // The list owns the top spacing AppWavedView drops when a scroll
          // controller is wired in, so it scrolls up with the cards and
          // flattens the wave.
          layout: PaginatedListLayout(
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 16),
            padding: const EdgeInsets.only(top: 57),
          ),
          placeholderBuilder: (_) => const DiscountCardShimmer(),
          nextPagePlaceholdersCount: 3,
          emptyBuilder: (_) => NoResultsWidget(
            isScrollable: true,
            emptyMessage: LangKeys.noItemsYetKey.tr(),
          ),
          itemBuilder: (BuildContext context, CouponModel coupon, int index) =>
              DiscountCard(
                coupon: coupon,
                dark: index.isOdd,
                onCopy: () => CopyToClipboard.copy(context, coupon.code ?? ''),
              ),
        ),
      ),
    );
  }
}
