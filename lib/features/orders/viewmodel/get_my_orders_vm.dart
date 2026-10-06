import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

/// The signed-in user's orders, page by page.
///
/// Kept alive and listed in `sessionScopedProviders`: the session loads the
/// first page at sign-in, the cart's welcome-voucher banner reads its `total`,
/// and the My Orders tab [GetMyOrdersViewModel.refresh]es it on every open.
/// `loadNextPage()` and `loadFirstPage()` (pull-to-refresh, retry) come from
/// [PaginatedViewModel].
final getMyOrdersProvider =
    StateNotifierProvider<
      GetMyOrdersViewModel,
      AsyncValue<PaginationModel<OrderModel>>
    >((Ref ref) => GetMyOrdersViewModel());

class GetMyOrdersViewModel extends PaginatedViewModel<OrderModel> {
  final OrdersRepo _repo = OrdersRepo();

  @override
  Future<Either<Failure, PaginationModel<OrderModel>>> fetchPage(int page) =>
      _repo.getMyOrders(page: page);

  @override
  bool Function(OrderModel, OrderModel)? get isSameItem => _isSameOrder;

  /// Same order: by [OrderModel.uuid], falling back to [OrderModel.id].
  static bool _isSameOrder(OrderModel a, OrderModel b) => a.uuid != null
      ? a.uuid == b.uuid
      : a.id != null && a.id == b.id;

  /// The first-page load on its way, if any. The initial state is "loading"
  /// too, so the state alone can't tell a load in flight from one that never
  /// started — which left the tab on a spinner forever.
  Future<void>? _firstLoad;

  /// A second call while a first-page load is on its way joins it instead of
  /// firing another request.
  @override
  Future<void> loadFirstPage() => _firstLoad ??= super
      .loadFirstPage()
      .whenComplete(() => _firstLoad = null);

  /// Loads the first page again while the loaded list stays on screen, and
  /// keeps that list if the request fails — for opening the tab, where
  /// statuses have moved on (pending → delivered) since the list was loaded at
  /// sign-in.
  ///
  /// Without a list yet it is a plain first load (the sign-in load failed, or
  /// never ran), joining the one on its way if there is one.
  Future<void> refresh() async {
    if (!state.hasValue) {
      await loadFirstPage();
      return;
    }

    final Either<Failure, PaginationModel<OrderModel>> result = await fetchPage(
      PaginatedViewModel.firstPageNumber,
    );

    if (!mounted) return;

    result.fold(
      (Failure _) {},
      (PaginationModel<OrderModel> firstPage) =>
          state = AsyncValue<PaginationModel<OrderModel>>.data(firstPage),
    );
  }

  /// Replaces the loaded copy of [order] in place — so a status change seen
  /// on the details or cancel flow shows in the list without a refetch. A
  /// no-op when the list isn't loaded or doesn't hold it.
  void updateOrder(OrderModel order) => updateItemsWhere(
    (OrderModel existing) => _isSameOrder(existing, order),
    (_) => order,
  );

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
