import '../core/json_utils.dart';
import 'hadith.dart';
import 'hadith_book.dart';

/// Metadata paginasi dari endpoint daftar hadis.
class Pagination {
  const Pagination({
    required this.totalItems,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  final int totalItems;
  final int currentPage;
  final int pageSize;
  final int totalPages;

  bool get hasNextPage => currentPage < totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: parseIntValue(json['totalItems']),
      currentPage: parseIntValue(json['currentPage'], fallback: 1),
      pageSize: parseIntValue(json['pageSize']),
      totalPages: parseIntValue(json['totalPages'], fallback: 1),
    );
  }
}

/// Satu halaman daftar hadis dari `GET /hadith/{slug}?page=&limit=`.
class HadithPage {
  const HadithPage({
    required this.book,
    required this.pagination,
    required this.items,
  });

  final HadithBook book;
  final Pagination pagination;
  final List<Hadith> items;

  factory HadithPage.fromJson(Map<String, dynamic> json) {
    final book = HadithBook.fromJson(json);
    final rawItems = json['items'];

    final items = <Hadith>[];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          items.add(
            Hadith.fromJson(
              raw,
              bookName: book.name,
              bookSlug: book.slug,
            ),
          );
        }
      }
    }

    final paginationJson = json['pagination'];
    return HadithPage(
      book: book,
      pagination: Pagination.fromJson(
        paginationJson is Map<String, dynamic> ? paginationJson : const {},
      ),
      items: items,
    );
  }
}
