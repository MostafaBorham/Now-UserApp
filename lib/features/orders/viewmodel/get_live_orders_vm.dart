import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_endpoints.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

/// Single task: keep the signed-in user's in-flight orders fresh for the home
/// live-orders strip.
///
/// `autoDispose`, and only watched by `HomeView` for a signed-in user, so it
/// dies on logout and nothing user-scoped outlives the session.
final getLiveOrdersProvider =
    StateNotifierProvider.autoDispose<
      GetLiveOrdersViewModel,
      AsyncValue<List<OrderModel>>
    >((Ref ref) => GetLiveOrdersViewModel()..start());

class GetLiveOrdersViewModel
    extends StateNotifier<AsyncValue<List<OrderModel>>> {
  GetLiveOrdersViewModel() : super(const AsyncValue.loading());

  static const Duration refreshInterval = Duration(seconds: 10);

  final OrdersRepo _repo = OrdersRepo();

  Timer? _refreshTimer;
  AppLifecycleListener? _lifecycle;
  bool _isFetching = false;

  /// Fetches now and then every [refreshInterval] — but only while the app is
  /// in the foreground. `HomeView` stays mounted behind the other tabs, so
  /// without the pause this polled from the background for as long as the
  /// process lived.
  void start() {
    _lifecycle = AppLifecycleListener(
      onStateChange: (AppLifecycleState lifecycleState) =>
          lifecycleState == AppLifecycleState.resumed
          ? _startPolling()
          : _refreshTimer?.cancel(),
    );
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    getLiveOrders();
    _refreshTimer = Timer.periodic(refreshInterval, (_) => getLiveOrders());
  }

  Future<void> getLiveOrders() async {
    if (_isFetching) return;
    _isFetching = true;

    final Either<Failure, PaginationModel<OrderModel>> result = await _repo
        .getMyOrders(page: 1, statuses: OrdersEndpoints.liveStatuses);

    _isFetching = false;
    if (!mounted) return;

    result.fold(
      (Failure failure) {
        // A failed refresh keeps the strip that is showing. Only a first load
        // with nothing to show records the error, and the strip stays hidden.
        if (state.hasValue) return;
        state = AsyncValue<List<OrderModel>>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<OrderModel> orders) =>
          state = AsyncValue<List<OrderModel>>.data(orders.data),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _lifecycle?.dispose();
    _repo.cancelRequests();
    super.dispose();
  }
}
