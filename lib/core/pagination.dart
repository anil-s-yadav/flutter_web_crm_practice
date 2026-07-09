class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasMore
  });

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasPrevious => currentPage > 1;
  bool get isEmpty => items.isEmpty;
}

class PaginationParams {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortField;
  final bool sortAscending;
  final Map<String, dynamic> filters;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 50,
    this.searchQuery,
    this.sortField,
    this.sortAscending = true,
    this.filters = const {}
  });

  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? searchQuery,
    String? sortField,
    bool? sortAscending,
    Map<String, dynamic>? filters
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filters: filters ?? this.filters
    );
  }
}
