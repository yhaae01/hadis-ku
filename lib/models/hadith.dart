import '../core/json_utils.dart';

/// Satu hadis beserta teks Arab dan terjemahan Indonesia.
class Hadith {
  const Hadith({
    required this.number,
    required this.arabic,
    required this.translation,
    required this.bookName,
    required this.bookSlug,
  });

  final int number;
  final String arabic;
  final String translation;
  final String bookName;
  final String bookSlug;

  factory Hadith.fromJson(
    Map<String, dynamic> json, {
    String bookName = '',
    String bookSlug = '',
  }) {
    return Hadith(
      number: parseIntValue(json['number']),
      arabic: (json['arab'] ?? '').toString(),
      // API memakai field "id" untuk terjemahan bahasa Indonesia.
      translation: (json['id'] ?? '').toString(),
      bookName: (json['name'] ?? bookName).toString(),
      bookSlug: (json['slug'] ?? bookSlug).toString(),
    );
  }
}
