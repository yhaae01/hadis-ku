import '../core/json_utils.dart';

/// Satu kitab/perawi hadis yang tersedia di API.
class HadithBook {
  const HadithBook({
    required this.name,
    required this.slug,
    required this.total,
  });

  final String name;
  final String slug;
  final int total;

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      total: parseIntValue(json['total']),
    );
  }
}
