import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';




class _TestViewModel extends PaginatedViewModel<int> {
  int loadFirstPageCalls = 0;

  AsyncValue<PaginationModel<int>> get currentState => state;

  void seed(PaginationModel<int> page) =>
      state = AsyncValue<PaginationModel<int>>.data(page);

  @override
  Future<void> loadFirstPage() async {
    loadFirstPageCalls++;
  }

  @override
  Future<Either<Failure, PaginationModel<int>>> fetchPage(int page) =>
      throw UnimplementedError('the test view-model must not fetch');
}

PaginationModel<int> _page(List<int> data, {bool hasMore = false}) =>
    PaginationModel<int>(
      currentPage: 1,
      lastPage: hasMore ? 2 : 1,
      perPage: 15,
      total: data.length,
      hasMore: hasMore,
      data: data,
    );

void main() {
  group('PaginatedViewModel.removeItemsWhere', () {
    test('drops matching items in place and decrements the total', () {
      final _TestViewModel vm = _TestViewModel()..seed(_page(<int>[1, 2, 3]));

      vm.removeItemsWhere((int i) => i == 2);

      expect(vm.currentState.valueOrNull!.data, <int>[1, 3]);
      expect(vm.currentState.valueOrNull!.total, 2);
      expect(vm.loadFirstPageCalls, 0);
      vm.dispose();
    });

    test('is a no-op when nothing matches', () {
      final _TestViewModel vm = _TestViewModel()..seed(_page(<int>[1, 2, 3]));

      vm.removeItemsWhere((int i) => i == 99);

      expect(vm.currentState.valueOrNull!.data, <int>[1, 2, 3]);
      expect(vm.loadFirstPageCalls, 0);
      vm.dispose();
    });

    test('reloads the first page when the page empties but more remain', () {
      final _TestViewModel vm =
          _TestViewModel()..seed(_page(<int>[1], hasMore: true));

      vm.removeItemsWhere((int i) => i == 1);

      expect(vm.loadFirstPageCalls, 1);
      vm.dispose();
    });

    test('shows an empty page when the last item goes and there is no more', () {
      final _TestViewModel vm =
          _TestViewModel()..seed(_page(<int>[1], hasMore: false));

      vm.removeItemsWhere((int i) => i == 1);

      expect(vm.currentState.valueOrNull!.data, isEmpty);
      expect(vm.loadFirstPageCalls, 0);
      vm.dispose();
    });

    test('is a no-op before the first page has loaded', () {
      final _TestViewModel vm = _TestViewModel();

      vm.removeItemsWhere((int i) => true);

      expect(vm.currentState.hasValue, isFalse);
      expect(vm.loadFirstPageCalls, 0);
      vm.dispose();
    });
  });
}
