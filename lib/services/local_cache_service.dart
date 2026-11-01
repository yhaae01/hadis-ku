import 'package:hive_ce_flutter/hive_flutter.dart';

import '../core/text_normalizer.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../models/hadith_page.dart';

/// Penyimpanan lokal berbasis Hive untuk mode offline.
///
/// Box yang dipakai:
/// - [booksBoxName]  : data kitab, key = slug kitab.
/// - [hadithsBoxName]: hadis yang pernah di-fetch, key = `{slug}_{nomor}`.
///
/// Setiap data yang berhasil diambil dari API disimpan di sini, sehingga
/// ketika perangkat kehilangan koneksi, daftar kitab, daftar hadis, detail
/// hadis, dan hasil pencarian yang pernah dilihat tetap tersedia.
class LocalCacheService {
  static const String booksBoxName = 'hadis_books';
  static const String hadithsBoxName = 'hadis_hadiths';

  late Box<dynamic> _booksBox;
  late Box<dynamic> _hadithsBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Buka semua box yang dibutuhkan.
  ///
  /// [dir] opsional untuk tujuan pengujian; pada aplikasi akan memakai
  /// direktori dokumen aplikasi bawaan platform.
  Future<void> init({String? dir}) async {
    if (_initialized) return;

    if (dir == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(dir);
    }

    _booksBox = await Hive.openBox<dynamic>(booksBoxName);
    _hadithsBox = await Hive.openBox<dynamic>(hadithsBoxName);
    _initialized = true;
  }

  static String hadithKey(String slug, int number) => '${slug}_$number';

  // --------------------------------------------------------------------------
  // Kitab
  // --------------------------------------------------------------------------

  Future<void> saveBooks(List<HadithBook> books) async {
    if (books.isEmpty) return;

    await _booksBox.putAll({
      for (final book in books) book.slug: book.toJson(),
    });
  }

  Future<void> saveBook(HadithBook book) {
    return _booksBox.put(book.slug, book.toJson());
  }

  HadithBook? getBook(String slug) {
    final raw = _booksBox.get(slug);
    if (raw is! Map) return null;
    return HadithBook.fromJson(Map<String, dynamic>.from(raw));
  }

  List<HadithBook> getBooks() {
    final books = <HadithBook>[];
    for (final raw in _booksBox.values) {
      if (raw is Map) {
        books.add(HadithBook.fromJson(Map<String, dynamic>.from(raw)));
      }
    }

    return books..sort((a, b) => a.name.compareTo(b.name));
  }

  // --------------------------------------------------------------------------
  // Hadis
  // --------------------------------------------------------------------------

  Future<void> saveHadith(Hadith hadith) {
    return _hadithsBox.put(
      hadithKey(hadith.bookSlug, hadith.number),
      hadith.toJson(),
    );
  }

  Future<void> saveHadiths(List<Hadith> hadiths) async {
    if (hadiths.isEmpty) return;

    await _hadithsBox.putAll({
      for (final hadith in hadiths)
        hadithKey(hadith.bookSlug, hadith.number): hadith.toJson(),
    });
  }

  Hadith? getHadith(String slug, int number) {
    final raw = _hadithsBox.get(hadithKey(slug, number));
    if (raw is! Map) return null;
    return Hadith.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Semua hadis milik [slug] (atau seluruh cache bila null), diurutkan
  /// berdasarkan kitab lalu nomor hadis.
  List<Hadith> getCachedHadiths({String? slug}) {
    final items = <Hadith>[];

    for (final raw in _hadithsBox.values) {
      if (raw is! Map) continue;
      final hadith = Hadith.fromJson(Map<String, dynamic>.from(raw));
      if (slug != null && hadith.bookSlug != slug) continue;
      items.add(hadith);
    }

    return items..sort((a, b) {
        final byBook = a.bookName.compareTo(b.bookName);
        if (byBook != 0) return byBook;
        return a.number.compareTo(b.number);
      });
  }

  /// Menyusun ulang halaman daftar hadis dari cache lokal.
  ///
  /// [totalItems] pada hasil diisi dengan jumlah hadis yang benar-benar
  /// tersimpan offline, bukan jumlah total kitab, agar UI tidak menjanjikan
  /// halaman yang belum ada di perangkat.
  HadithPage? getHadithsPage(
    String slug, {
    required int page,
    required int limit,
  }) {
    final cached = getCachedHadiths(slug: slug);
    if (cached.isEmpty) return null;

    final totalPages = (cached.length / limit).ceil();
    if (page < 1 || page > totalPages) return null;

    final start = (page - 1) * limit;
    final end = start + limit < cached.length ? start + limit : cached.length;

    final book = getBook(slug) ??
        HadithBook(name: cached.first.bookName, slug: slug, total: cached.length);

    return HadithPage(
      book: book,
      pagination: Pagination(
        totalItems: cached.length,
        currentPage: page,
        pageSize: limit,
        totalPages: totalPages,
      ),
      items: cached.sublist(start, end),
    );
  }

  /// Pencarian teks pada seluruh data yang tersimpan di perangkat.
  List<Hadith> searchCachedHadiths(
    Iterable<String> keywords, {
    String? slug,
    int limit = 30,
  }) {
    final needles = keywords
        .map((keyword) => normalizeForSearch(keyword))
        .where((keyword) => keyword.isNotEmpty)
        .toList(growable: false);

    if (needles.isEmpty) return [];

    final results = <Hadith>[];

    for (final hadith in getCachedHadiths(slug: slug)) {
      final arabic = normalizeForSearch(hadith.arabic);
      final translation = normalizeForSearch(hadith.translation);

      final matches = needles.any(
        (keyword) => arabic.contains(keyword) || translation.contains(keyword),
      );

      if (matches) {
        results.add(hadith);
        if (results.length >= limit) break;
      }
    }

    return results;
  }

  int get cachedHadithCount => _hadithsBox.length;
}
