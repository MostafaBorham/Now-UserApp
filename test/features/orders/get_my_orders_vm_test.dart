import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';

/// Answers [fetchPage] from [answers] in order and counts the calls, so
/// `refresh` can be driven without a network.
class _ScriptedOrdersVM extends GetMyOrdersViewModel {
  _ScriptedOrdersVM(this.answers);

  final List<Either<Failure, PaginationModel<OrderModel>>> answers;
  int fetches = 0;

  AsyncValue<PaginationModel<OrderModel>> get current => state;

  void seed(AsyncValue<PaginationModel<OrderModel>> value) => state = value;

  @override
  Future<Either<Failure, PaginationModel<OrderModel>>> fetchPage(
    int page,
  ) async => answers[fetches++];
}

PaginationModel<OrderModel> _page(List<String> statuses) =>
    PaginationModel<OrderModel>(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: statuses.length,
      hasMore: false,
      data: <OrderModel>[
        for (int i = 0; i < statuses.length; i++)
          OrderModel(uuid: 'o$i', status: statuses[i]),
      ],
    );

List<String?> _statuses(_ScriptedOrdersVM vm) => vm.current.requireValue.data
    .map((OrderModel o) => o.status)
    .toList();

void main() {
  test('opening the tab brings in the new statuses', () async {
    final _ScriptedOrdersVM vm = _ScriptedOrdersVM(
      <Either<Failure, PaginationModel<OrderModel>>>[
        Right(_page(<String>['delivered'])),
      ],
    )..seed(AsyncValue.data(_page(<String>['pending'])));

    await vm.refresh();

    expect(_statuses(vm), <String>['delivered']);
  });

  test('a failed refresh keeps the list on screen', () async {
    final _ScriptedOrdersVM vm = _ScriptedOrdersVM(
      <Either<Failure, PaginationModel<OrderModel>>>[
        const Left(Failure('offline')),
      ],
    )..seed(AsyncValue.data(_page(<String>['pending'])));

    await vm.refresh();

    expect(vm.current.hasError, isFalse);
    expect(_statuses(vm), <String>['pending']);
  });

  test('a load in flight is not repeated', () async {
    final _ScriptedOrdersVM vm = _ScriptedOrdersVM(
      <Either<Failure, PaginationModel<OrderModel>>>[
        Right(_page(<String>['pending'])),
      ],
    );

    final Future<void> signInLoad = vm.loadFirstPage();
    await vm.refresh();
    await signInLoad;

    expect(vm.fetches, 1);
    expect(_statuses(vm), <String>['pending']);
  });

  test('a load that never started is started (BUG-011, QA V2)', () async {
    // The initial state is "loading" with nothing on its way: the tab used to
    // wait on it forever.
    final _ScriptedOrdersVM vm = _ScriptedOrdersVM(
      <Either<Failure, PaginationModel<OrderModel>>>[
        Right(_page(<String>['pending'])),
      ],
    );

    await vm.refresh();

    expect(vm.fetches, 1);
    expect(_statuses(vm), <String>['pending']);
  });

  test('after a failed sign-in load it loads the first page', () async {
    final _ScriptedOrdersVM vm = _ScriptedOrdersVM(
      <Either<Failure, PaginationModel<OrderModel>>>[
        Right(_page(<String>['accepted'])),
      ],
    )..seed(AsyncValue.error('offline', StackTrace.empty));

    await vm.refresh();

    expect(_statuses(vm), <String>['accepted']);
  });
}
