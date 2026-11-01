/// Referensi hadis pilihan untuk sebuah topik.
class HadithReference {
  const HadithReference({required this.slug, required this.number});

  final String slug;
  final int number;
}

/// Topik/kategori hadis yang tampil di beranda.
class HadithTopic {
  const HadithTopic({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.keywords,
    required this.references,
  });

  final String id;
  final String title;
  final String arabicTitle;
  final String description;

  /// Kata kunci untuk mencari hadis terkait di cache lokal.
  final List<String> keywords;

  /// Hadis pilihan yang diambil langsung berdasarkan kitab dan nomornya.
  final List<HadithReference> references;
}
