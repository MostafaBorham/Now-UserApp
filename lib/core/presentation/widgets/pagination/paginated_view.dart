import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/pagination_scroll_listener.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';

/// Renders a paginated list of [T] driven by a `PaginatedViewModel`: infinite
/// scroll, pull-to-refresh, first-page shimmer and error, empty state, and a
/// trailing shimmer while the next page loads.
///
/// A failed *next* page never interrupts the list: it is reported as a snackbar
/// and nothing else changes, so reaching the end of the list simply asks for
/// that page again — for as long as the server says there is more. Only a failed
/// *first* page takes over the view, since there would be nothing to show.
///
/// Reusable as-is by any screen that pages through items — it only needs the
/// provider to watch, the two callbacks that ask for pages, how one item looks
/// ([itemBuilder]) and how they are arranged ([layout]).
///
/// ```dart
/// PaginatedView<ProductModel>(
///   provider: getCategoryProductsProvider,
///   onRefresh: viewModel.loadFirstPage,
///   onLoadNextPage: viewModel.loadNextPage,
///   layout: const PaginatedGridLayout(gridDelegate: ...),
///   placeholderBuilder: (_) => AppShimmer(child: ProductItemCard2()),
///   itemBuilder: (_, ProductModel product, __) =>
///       ProductItemCard2(productModel: product),
/// )
/// ```
class PaginatedView<T> extends ConsumerWidget {
  const PaginatedView({
    super.key,
    required this.provider,
    required this.onRefresh,
    required this.onLoadNextPage,
    required this.itemBuilder,
    required this.layout,
    this.placeholderBuilder,
    this.firstPageLoadingBuilder,
    this.firstPagePlaceholdersCount = 4,
    this.nextPagePlaceholdersCount = 4,
    this.emptyBuilder,
    this.nextPageThreshold = 200,
  }) : assert(
          placeholderBuilder != null || firstPageLoadingBuilder != null,
          'A first-page loading state is required: give a placeholderBuilder, '
          'or a firstPageLoadingBuilder to replace the whole view.',
        );

  /// The view-model state to render. Any listenable of the pagination state
  /// fits, so the view stays unaware of which feature it is serving.
  final ProviderListenable<AsyncValue<PaginationModel<T>>> provider;

  /// Loads the first page again: the pull-to-refresh gesture and the retry on a
  /// failed first page.
  final Future<void> Function() onRefresh;

  /// Asks for the page after the loaded ones. Called on approaching the end of
  /// the list and on tapping the footer retry; the view model decides whether a
  /// request actually goes out.
  final VoidCallback onLoadNextPage;

  /// Builds one loaded item.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// How the items are arranged — grid, list, … See [PaginatedSliverLayout].
  final PaginatedSliverLayout layout;

  /// Builds one skeleton item — typically the item itself wrapped in
  /// `AppShimmer`. Used for both loading states: it fills the view while the
  /// first page loads and trails the loaded items while the next page does, so
  /// the skeleton is laid out by [layout] exactly like the real items and its
  /// geometry is described only once.
  final WidgetBuilder? placeholderBuilder;

  /// Replaces the whole view while the first page loads, for screens whose
  /// loading state is not simply skeleton items in [layout] (a bespoke shimmer,
  /// say). Takes precedence over [placeholderBuilder] for that state.
  final WidgetBuilder? firstPageLoadingBuilder;

  /// How many [placeholderBuilder] skeletons fill the view while the first page
  /// loads.
  final int firstPagePlaceholdersCount;

  /// How many [placeholderBuilder] skeletons trail the items while the next page
  /// loads. Zero leaves the list unchanged while it loads.
  final int nextPagePlaceholdersCount;

  /// Replaces the default [NoResultsWidget] shown when the first page comes back
  /// with no items.
  final WidgetBuilder? emptyBuilder;

  /// How far from the end of the list the next page starts loading.
  final double nextPageThreshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Surface a next-page failure as a snackbar the moment state turns to error
    // while items are already on screen — the full-screen error widget covers
    // the first-page failure, so that case is skipped.
    ref.listen(provider, (
      AsyncValue<PaginationModel<T>>? previous,
      AsyncValue<PaginationModel<T>> next,
    ) {
      // Keying off "previous was loading" (rather than "was not already error")
      // is what lets a second, third… retry failure surface again: after a retry
      // the error still lingers in state under the loading flag, so a
      // "was error" guard would swallow every failure after the first.
      if (previous?.isLoading != true) return;

      final String? nextPageError =
          PaginationStatus<T>.from(next).nextPageError;
      if (nextPageError == null) return;

      ErrorSnackBar.show(context, nextPageError);
    });

    final PaginationStatus<T> status =
        PaginationStatus<T>.from(ref.watch(provider));

    // Nothing loaded yet, so loading and error own the whole view.
    final String? firstPageError = status.firstPageError;
    if (firstPageError != null) {
      return ServerConnectionErrorWidget(
        message: firstPageError,
        onRetry: onRefresh,
        isScrollable: true,
      );
    }
    if (!status.hasLoadedPage) {
      final WidgetBuilder? firstPageLoadingBuilder =
          this.firstPageLoadingBuilder;
      if (firstPageLoadingBuilder != null) {
        return firstPageLoadingBuilder(context);
      }
      // Skeletons in the real layout: same arrangement, same item geometry.
      return CustomScrollView(
        slivers: <Widget>[
          layout.buildSliver(
            itemCount: firstPagePlaceholdersCount,
            itemBuilder: (BuildContext context, int index) =>
                placeholderBuilder!(context),
          ),
        ],
      );
    }

    // Skeletons trail the loaded items while the next page is on its way — only
    // when there is a builder for them.
    final int trailingPlaceholders =
        status.isNextPageLoading && placeholderBuilder != null
            ? nextPagePlaceholdersCount
            : 0;

    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: status.isEmpty
          ? (emptyBuilder?.call(context) ??
              const NoResultsWidget(isScrollable: true))
          : PaginationScrollListener(
              canLoadNextPage: status.canRequestNextPage,
              threshold: nextPageThreshold,
              onLoadNextPage: onLoadNextPage,
              // A failed next page leaves the list untouched — no footer, no
              // retry affordance: the snackbar reports it and reaching the end
              // again asks for the same page again.
              child: CustomScrollView(
                slivers: <Widget>[
                  layout.buildSliver(
                    itemCount: status.items.length + trailingPlaceholders,
                    itemBuilder: (BuildContext context, int index) {
                      // Past the loaded items: one of the next-page skeletons,
                      // which only exist when there is a builder for them.
                      if (index >= status.items.length) {
                        return placeholderBuilder!(context);
                      }
                      return itemBuilder(context, status.items[index], index);
                    },
                  ),
                ],
              ),
            ),
    );
  }

}
