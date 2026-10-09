class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  int get totalPages => (totalCount / (pageSize > 0 ? pageSize : 1)).ceil();
}
