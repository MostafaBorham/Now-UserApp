import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// The my-orders list as it comes back from local storage: the accumulated
/// paginated [orders] plus [isUpdated], the flag telling whether that cached
/// copy still matches the server.
///
/// [isUpdated] is `true` when the cache was last written straight from a
/// successful server fetch, and `false` when a cache write failed (so the local
/// copy has drifted from the server) or when nothing has been cached yet.
class CachedOrdersModel {
  final PaginationModel<OrderModel> orders;
  final bool isUpdated;

  const CachedOrdersModel({required this.orders, required this.isUpdated});

  /// An empty cache — no stored orders and, therefore, not in sync.
  static const CachedOrdersModel empty = CachedOrdersModel(
    orders: PaginationModel<OrderModel>(
      currentPage: 1,
      lastPage: 1,
      perPage: 0,
      total: 0,
      hasMore: false,
      data: <OrderModel>[],
    ),
    isUpdated: false,
  );
}
