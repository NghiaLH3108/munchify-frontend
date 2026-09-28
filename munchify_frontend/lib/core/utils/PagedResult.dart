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
}
