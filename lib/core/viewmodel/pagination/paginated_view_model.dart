import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';


























abstract class PaginatedViewModel<T>
    extends StateNotifier<AsyncValue<PaginationModel<T>>> {
  PaginatedViewModel() : super(const AsyncValue.loading());


  static const int firstPageNumber = 1;



  @protected
  Future<Either<Failure, PaginationModel<T>>> fetchPage(int page);






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





  void removeItemsWhere(bool Function(T item) test) {
    final PaginationModel<T>? current = state.valueOrNull;
    if (current == null) return;

    final List<T> remaining =
        current.data.where((T item) => !test(item)).toList();
    final int removed = current.data.length - remaining.length;
    if (removed == 0) return;






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



  PaginationStatus<T> get status => PaginationStatus<T>.from(state);
}
