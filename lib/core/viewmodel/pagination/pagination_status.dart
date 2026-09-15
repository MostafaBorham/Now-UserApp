import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';

class PaginationStatus<T> {
  const PaginationStatus._({
    required this.items,
    required this.hasLoadedPage,
    required this.hasMore,
    required this.isFirstPageLoading,
    required this.firstPageError,
    required this.isNextPageLoading,
    required this.nextPageError,
  });

  factory PaginationStatus.from(AsyncValue<PaginationModel<T>> asyncState) {
    final PaginationModel<T>? page = asyncState.valueOrNull;
    final bool hasPage = page != null;

    final bool hasSettledError = asyncState.hasError && !asyncState.isLoading;
    final String? errorMessage =
        hasSettledError ? asyncState.error.toString() : null;

    return PaginationStatus<T>._(
      items: page?.data ?? <T>[],
      hasLoadedPage: hasPage,
      hasMore: page?.hasMore ?? false,
      isFirstPageLoading: !hasPage && asyncState.isLoading,
      firstPageError: hasPage ? null : errorMessage,
      isNextPageLoading: hasPage && asyncState.isLoading,
      nextPageError: hasPage ? errorMessage : null,
    );
  }

  final List<T> items;

  final bool hasLoadedPage;

  final bool hasMore;

  final bool isFirstPageLoading;

  final String? firstPageError;

  final bool isNextPageLoading;

  final String? nextPageError;

  bool get isEmpty => hasLoadedPage && items.isEmpty;

  bool get canRequestNextPage => hasLoadedPage && hasMore && !isNextPageLoading;
}
