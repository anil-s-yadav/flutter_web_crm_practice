import 'package:practice_app/core/pagination.dart';

class PaginatedState<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? searchQuery;
  final String? sortField;
  final bool sortAscending;
  final Map<String, dynamic> filters;
  final String? errorMessage;

  const PaginatedState({
    this.items = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 50,
    this.isLoading = false,
    this.searchQuery,
    this.sortField,
    this.sortAscending = true,
    this.filters = const {},
    this.errorMessage,
  });

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasPrevious => currentPage > 1;
  bool get hasNext => currentPage < totalPages;

  PaginationParams toPaginationParams() {
    return PaginationParams(
      page: currentPage,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortField: sortField,
      sortAscending: sortAscending,
      filters: filters,
    );
  }

  PaginatedState<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? isLoading,
    String? searchQuery,
    String? sortField,
    bool? sortAscending,
    Map<String, dynamic>? filters,
    String? errorMessage,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
