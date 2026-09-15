import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/pagination_scroll_listener.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';

























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
    this.scrollController,
    this.isFirstPageErrorScrollable = true,
    this.enablePullToRefresh = true,
  }) : assert(
          placeholderBuilder != null || firstPageLoadingBuilder != null,
          'A first-page loading state is required: give a placeholderBuilder, '
          'or a firstPageLoadingBuilder to replace the whole view.',
        );



  final ProviderListenable<AsyncValue<PaginationModel<T>>> provider;



  final Future<void> Function() onRefresh;




  final VoidCallback onLoadNextPage;


  final Widget Function(BuildContext context, T item, int index) itemBuilder;


  final PaginatedSliverLayout layout;






  final WidgetBuilder? placeholderBuilder;




  final WidgetBuilder? firstPageLoadingBuilder;



  final int firstPagePlaceholdersCount;



  final int nextPagePlaceholdersCount;



  final WidgetBuilder? emptyBuilder;


  final double nextPageThreshold;





  final ScrollController? scrollController;






  final bool isFirstPageErrorScrollable;






  final bool enablePullToRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {



    ref.listen(provider, (
      AsyncValue<PaginationModel<T>>? previous,
      AsyncValue<PaginationModel<T>> next,
    ) {




      if (previous?.isLoading != true) return;

      final String? nextPageError =
          PaginationStatus<T>.from(next).nextPageError;
      if (nextPageError == null) return;

      AppToast.showError(context, nextPageError);
    });

    final PaginationStatus<T> status =
        PaginationStatus<T>.from(ref.watch(provider));


    final String? firstPageError = status.firstPageError;
    if (firstPageError != null) {
      return ServerConnectionErrorWidget(
        message: firstPageError,
        onRetry: onRefresh,
        isScrollable: isFirstPageErrorScrollable,
      );
    }
    if (!status.hasLoadedPage) {
      final WidgetBuilder? firstPageLoadingBuilder =
          this.firstPageLoadingBuilder;
      if (firstPageLoadingBuilder != null) {
        return firstPageLoadingBuilder(context);
      }

      return CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          layout.buildSliver(
            itemCount: firstPagePlaceholdersCount,
            itemBuilder: (BuildContext context, int index) =>
                placeholderBuilder!(context),
          ),
        ],
      );
    }



    final int trailingPlaceholders =
        status.isNextPageLoading && placeholderBuilder != null
            ? nextPagePlaceholdersCount
            : 0;

    final Widget content = status.isEmpty
        ? (emptyBuilder?.call(context) ??
            const NoResultsWidget(isScrollable: true))
        : PaginationScrollListener(
            canLoadNextPage: status.canRequestNextPage,
            threshold: nextPageThreshold,
            onLoadNextPage: onLoadNextPage,



            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                layout.buildSliver(
                  itemCount: status.items.length + trailingPlaceholders,
                  itemBuilder: (BuildContext context, int index) {


                    if (index >= status.items.length) {
                      return placeholderBuilder!(context);
                    }
                    return itemBuilder(context, status.items[index], index);
                  },
                ),
              ],
            ),
          );

    if (!enablePullToRefresh) return content;

    return AppRefreshIndicator(onRefresh: onRefresh, child: content);
  }

}
