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
      (PaginationModel<T> nextPage) =>
          AsyncValue<PaginationModel<T>>.data(currentPage.appendPage(nextPage)),
    );
  }

  /// The current state read as pagination flags — the same reading the widget
  /// layer uses, so "may another page be requested?" is answered in one place.
  PaginationStatus<T> get status => PaginationStatus<T>.from(state);
}
