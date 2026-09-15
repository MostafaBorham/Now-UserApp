





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


      hasMore: json['has_more'] as bool? ?? currentPage < lastPage,
      data: dataList,
    );
  }




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
