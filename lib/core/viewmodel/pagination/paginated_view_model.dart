import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';

/// Page-by-page loading of a list of [T], independent of *what* is being
/// listed and of *how* it is fetched.
///
/// Subclasses supply the single missing piece — [fetchPage] — and inherit the
/// whole state machine: first page, next page, append, and the loading/error
/// bookkeeping every paginated screen would otherwise reimplement.
///
/// ```dart
/// class GetCategoryProductsViewModel extends PaginatedViewModel<ProductModel> {
///   @override
///   Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) =>
///       _repo.getCategoryProducts(page: page);
/// }
/// ```
///
/// The state contract the UI can rely on:
/// * first page in flight → `loading` with no value;
/// * first page failed → `error` with no value;
/// * next page in flight → `loading` **carrying the pages already loaded**;
/// * next page failed → `error` **carrying the pages already loaded**.
///
/// So "is there a value?" answers *is anything on screen yet?*, and the same
/// loading/error flags then mean "the next page" instead of "the list".
/// [PaginationStatus] does exactly that read, for this class and for the widget
/// layer alike.
abstract class PaginatedViewModel<T>
    extends StateNotifier<AsyncValue<PaginationModel<T>>> {
  PaginatedViewModel() : super(const AsyncValue.loading());

  /// The API is 1-based; [loadNextPage] counts up from the page in state.
  static const int firstPageNumber = 1;

  /// Fetches a single [page]. The only thing a subclass has to provide: query
  /// parameters, endpoint and parsing all stay in the feature's repo.
  @protected
  Future<Either<Failure, PaginationModel<T>>> fetchPage(int page);

  /// How two items are recognised as the same row, for dropping duplicates when
  /// a page is appended.
  ///
  /// Offset pagination shifts when rows are inserted server-side between two
  /// page requests, so an already-loaded item can arrive again on the next page.
  /// Override this wherever the list has a stable id and that would be visible.
  /// `null` (the default) appends without deduplication.
  @protected
  bool Function(T a, T b)? get isSameItem => null;

  /// Loads (or reloads) the first page, dropping whatever was loaded before.
  ///
  /// Used for the initial fetch, pull-to-refresh, and retrying a failed first
  /// page. Subclasses that take query parameters should store them and then
  /// delegate here, so a refresh replays the same query.
  Future<void> loadFirstPage() async {
    state = AsyncValue<PaginationModel<T>>.loading();

    final Either<Failure, PaginationModel<T>> result =
        await fetchPage(firstPageNumber);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<PaginationModel<T>>.error(
            failure.message,
            StackTrace.current,
          ),
      AsyncValue<PaginationModel<T>>.data,
    );
  }

  /// Loads the page after the one in state and appends it to the items already
  /// there.
  ///
  /// Unlike [loadFirstPage] this keeps the loaded items in state while the
  /// request is in flight — the state is loading *and* still carries its value
  /// — so the screen goes on showing the list and marks the new page as pending
  /// underneath it. A failure works the same way: the error lands in state
  /// without dropping the items.
  ///
  /// A no-op when [PaginationStatus.canRequestNextPage] is false, which makes it
  /// safe to call from a scroll notification on every frame.
  Future<void> loadNextPage() async {
    final PaginationModel<T>? currentPage = state.valueOrNull;
    if (currentPage == null || !status.canRequestNextPage) return;

    state =
        AsyncValue<PaginationModel<T>>.loading().copyWithPrevious(state);

    final Either<Failure, PaginationModel<T>> result =
        await fetchPage(currentPage.currentPage + 1);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<PaginationModel<T>>.error(
            failure.message,
            StackTrace.current,
          ).copyWithPrevious(state),
      (PaginationModel<T> nextPage) {
        // Append onto the *current* state, not the `currentPage` snapshot taken
        // before the await: an in-place edit ([updateItemsWhere] /
        // [removeItemsWhere]) may have landed while the page was in flight, and
        // appending onto the stale copy would silently undo it — unfavouriting a
        // row while the next page loaded used to bring the row back.
        final PaginationModel<T>? latest = state.valueOrNull;

        return AsyncValue<PaginationModel<T>>.data(
          latest == null
              ? nextPage
              : latest.appendPage(nextPage, isSameItem: isSameItem),
        );
      },
    );
  }

  /// Replaces every already-loaded item matching [test] with the result of
  /// [update], in place and without refetching — for reflecting a change made
  /// on a card back onto the list (e.g. a favourite toggle flipping
  /// `isFavorite` on the single item behind the tapped heart). Every other
  /// item keeps its identity, so a per-item `select` rebuilds only the changed
  /// cell. A no-op before the first page loads or when nothing matches.
  void updateItemsWhere(bool Function(T item) test, T Function(T item) update) {
    final PaginationModel<T>? current = state.valueOrNull;
    if (current == null) return;

    bool changed = false;
    final List<T> updated = <T>[];
    for (final T item in current.data) {
      if (test(item)) {
        updated.add(update(item));
        changed = true;
      } else {
        updated.add(item);
      }
    }
    if (!changed) return;

    state = AsyncValue<PaginationModel<T>>.data(current.copyWithData(updated));
  }

  /// Drops the already-loaded items matching [test] from the current page in
  /// place, without refetching — for when an item leaves the list as a side
  /// effect of something on the screen (e.g. unfavouriting on the favourites
  /// screen). A no-op before the first page loads or when nothing matches.
  void removeItemsWhere(bool Function(T item) test) {
    final PaginationModel<T>? current = state.valueOrNull;
    if (current == null) return;

    final List<T> remaining =
        current.data.where((T item) => !test(item)).toList();
    final int removed = current.data.length - remaining.length;
    if (removed == 0) return;

    // The visible page emptied out but the server still has more: reload the
    // first page (a fresh page, replaying the current filters) rather than
    // showing the empty state. loadFirstPage — not loadNextPage — because a
    // deletion shifts the server-side page offsets, so asking for "the next
    // page" would skip the items that moved down into the first one.
    if (remaining.isEmpty && current.hasMore) {
      loadFirstPage();
      return;
    }

    state = AsyncValue<PaginationModel<T>>.data(
      PaginationModel<T>(
        currentPage: current.currentPage,
        lastPage: current.lastPage,
        perPage: current.perPage,
        total: (current.total - removed).clamp(0, current.total),
        hasMore: current.hasMore,
        data: remaining,
      ),
    );
  }

  /// The current state read as pagination flags — the same reading the widget
  /// layer uses, so "may another page be requested?" is answered in one place.
  PaginationStatus<T> get status => PaginationStatus<T>.from(state);
}
