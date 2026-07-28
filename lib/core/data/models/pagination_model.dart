/// A page of [T] items plus the server's pagination envelope.
///
/// The API returns both under the same object — the items under `items` and the
/// page counters under `meta` — so [fromJson] takes that object and pulls both
/// out. Endpoints that name those keys differently can override [dataKey] and
/// [metaKey].
class PaginationModel<T> {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;
  final List<T> data;

  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
    required this.data,
  });

  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
    List<T> dataList) {

    return PaginationModel<T>(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? dataList.length,
      total: json['total'] as int? ?? dataList.length,
      hasMore: json['has_more'] as bool? ?? false,
      data: dataList,
    );
  }

  /// Merges a freshly fetched [nextPage] into this one: the counters come from
  /// [nextPage] (it is the page now loaded), the items are this page's followed
  /// by the new ones.
  PaginationModel<T> appendPage(PaginationModel<T> nextPage) {
    return PaginationModel<T>(
      currentPage: nextPage.currentPage,
      lastPage: nextPage.lastPage,
      perPage: nextPage.perPage,
      total: nextPage.total,
      hasMore: nextPage.hasMore,
      data: <T>[...data, ...nextPage.data],
    );
  }
}