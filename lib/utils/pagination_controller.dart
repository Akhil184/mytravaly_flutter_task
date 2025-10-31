class PaginationController {
  int page = 1;
  final int limit;
  int total = 0;

  PaginationController({this.limit = 20});

  void reset() {
    page = 1;
    total = 0;
  }

  void nextPage() => page++;

  bool get hasMore => (total == 0) ? true : (page * limit < total);
}
