import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';

/// Reads an `AsyncValue<PaginationModel<T>>` the way a paginated screen needs
/// it, so nobody has to reason about "loading with a value" or "error with a
/// value" at the call site.
///
/// The rule the whole pagination stack is built on: **whether there is a value
/// says what the loading/error flags are about.** No value yet → they describe
/// the list as a whole (full-screen shimmer / error). A value already loaded →
/// they describe the *next* page (trailing shimmer / footer retry), and the
/// items stay on screen either way.
///
/// One source of truth for that reading, shared by `PaginatedViewModel` (to
/// decide whether another page may be requested) and by `PaginatedView` (to
/// decide what to paint).
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

  /// Interprets [asyncState] — the raw view-model state — as view-level flags.
  factory PaginationStatus.from(AsyncValue<PaginationModel<T>> asyncState) {
    final PaginationModel<T>? page = asyncState.valueOrNull;
    final bool hasPage = page != null;

    // A retry leaves the previous error in state while it loads, so an error
    // only counts once nothing is in flight anymore.
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

  /// Every item loaded so far, across all pages.
  final List<T> items;

  /// Whether a page ever arrived — so whether anything is on screen, and with
  /// it whether the flags below are about the list or about the next page.
  final bool hasLoadedPage;

  /// Whether the server said there are more pages after the loaded ones.
  final bool hasMore;

  /// Nothing loaded yet and the first page is on its way.
  final bool isFirstPageLoading;

  /// Nothing loaded and the first page failed; the message to show full-screen.
  final String? firstPageError;

  /// Items are on screen and another page is on its way.
  final bool isNextPageLoading;

  /// Items are on screen and the next page failed; the message to surface
  /// without disturbing them.
  final String? nextPageError;

  /// The first page arrived and reported no items at all.
  bool get isEmpty => hasLoadedPage && items.isEmpty;

  /// Whether requesting another page would do anything: something has to be
  /// loaded, the server has to have said there is more, and no other page may
  /// be in flight.
  ///
  /// A page that just failed still qualifies — a failure is reported (as a
  /// snackbar) but never ends the paging, so reaching the end of the list asks
  /// for it again as long as the server says [hasMore].
  bool get canRequestNextPage => hasLoadedPage && hasMore && !isNextPageLoading;
}
