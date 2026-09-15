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

    final int currentPage = json['current_page'] as int? ?? 1;
    final int lastPage = json['last_page'] as int? ?? 1;

    return PaginationModel<T>(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: json['per_page'] as int? ?? dataList.length,
      total: json['total'] as int? ?? dataList.length,
      // Endpoints that don't send `has_more` (e.g. `/api/v1/my/orders`) still
      // send the page counters, which say the same thing.
      hasMore: json['has_more'] as bool? ?? currentPage < lastPage,
      data: dataList,
    );
  }

  /// Returns a copy holding [data] in place of the current items while keeping
  /// every page counter untouched. Used for in-place list edits (optimistic
  /// add / update / remove) that don't change which page is loaded.
  PaginationModel<T> copyWithData(List<T> data) {
    return PaginationModel<T>(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasMore: hasMore,
      data: data,
    );
  }

  /// Merges a freshly fetched [nextPage] into this one: the counters come from
  /// [nextPage] (it is the page now loaded), the items are this page's followed
  /// by the new ones.
  ///
  /// Pass [isSameItem] to drop an incoming item that is already loaded. Offset
  /// pagination shifts when rows are inserted server-side between two page
  /// requests, so an item from the end of page 1 can arrive again at the start
  /// of page 2 — appending blindly then shows it twice. Omitted, the merge is a
  /// plain concatenation, which is what a list with no stable identity wants.
  PaginationModel<T> appendPage(
    PaginationModel<T> nextPage, {
    bool Function(T a, T b)? isSameItem,
  }) {
    final List<T> merged = <T>[...data];

    for (final T item in nextPage.data) {
      // ponytail: linear scan per incoming item, so O(page × loaded). Fine for
      // pages of 15 over a few hundred rows; index the identity into a Set if a
      // list ever grows big enough to feel it.
      final bool alreadyLoaded = isSameItem != null &&
          merged.any((T existing) => isSameItem(existing, item));
      if (alreadyLoaded) continue;

      merged.add(item);
    }

    return PaginationModel<T>(
      currentPage: nextPage.currentPage,
      lastPage: nextPage.lastPage,
      perPage: nextPage.perPage,
      total: nextPage.total,
      hasMore: nextPage.hasMore,
      data: merged,
    );
  }
}