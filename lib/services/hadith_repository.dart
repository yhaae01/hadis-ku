import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../core/fetch_result.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../models/hadith_page.dart';
import 'hadith_api_service.dart';
import 'local_cache_service.dart';

/// Menggabungkan [HadithApiService] (jaringan) dan [LocalCacheService]
/// (Hive) dengan strategi **network-first, cache fallback**:
///
/// 1. Coba ambil data dari API.
/// 2. Simpan hasilnya ke Hive (kitab, halaman daftar, detail hadis, hasil
///    pencarian).
/// 3. Bila API gagal (offline / server bermasalah), layani dari cache dan
///    tandai hasil dengan [FetchResult.fromCache].
class HadithRepository {
  HadithRepository({required this.cache, HadithApiService? api})
      : _api = api ?? HadithApiService();

  final LocalCacheService cache;
  final HadithApiService _api;

  Future<FetchResult<List<HadithBook>>> fetchBooks() async {
    try {
      final books = await _api.fetchBooks();
      await _tryCache(() => cache.saveBooks(books));
      return FetchResult(books);
    } on ApiException {
      final cached = cache.getBooks();
      if (cached.isNotEmpty) return FetchResult(cached, fromCache: true);
      rethrow;
    }
  }

  Future<FetchResult<HadithPage>> fetchHadiths(
    String slug, {
    int page = 1,
    int limit = ApiConfig.pageSize,
  }) async {
    try {
      final result = await _api.fetchHadiths(slug, page: page, limit: limit);

      await _tryCache(() async {
        await cache.saveBook(result.book);
        await cache.saveHadiths(result.items);
      });

      return FetchResult(result);
    } on ApiException {
      final cached = cache.getHadithsPage(slug, page: page, limit: limit);
      if (cached != null && cached.items.isNotEmpty) {
        return FetchResult(cached, fromCache: true);
      }
      rethrow;
    }
  }

  Future<FetchResult<Hadith>> fetchHadith(String slug, int number) async {
    try {
      final hadith = await _api.fetchHadith(slug, number);
      await _tryCache(() => cache.saveHadith(hadith));
      return FetchResult(hadith);
    } on ApiException {
      final cached = cache.getHadith(slug, number);
      if (cached != null) return FetchResult(cached, fromCache: true);
      rethrow;
    }
  }

  /// Pencarian: mencoba memindai API lalu menyimpan hasilnya; bila gagal,
  /// mencari di data lokal sebelum tetap dinyatakan gagal.
  Future<FetchResult<List<Hadith>>> searchHadiths({
    required String slug,
    required String keyword,
    void Function(int scannedPage, int totalPages)? onProgress,
    bool Function()? isCancelled,
  }) async {
    try {
      final results = await _api.searchHadiths(
        slug: slug,
        keyword: keyword,
        onProgress: onProgress,
        isCancelled: isCancelled,
      );

      await _tryCache(() => cache.saveHadiths(results));
      return FetchResult(results);
    } on ApiException {
      final local = cache.searchCachedHadiths(
        [keyword],
        slug: slug,
        limit: ApiConfig.maxSearchResults,
      );
      if (local.isNotEmpty) return FetchResult(local, fromCache: true);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Akses cache langsung (dipakai halaman topik agar tampil instan offline)
  // --------------------------------------------------------------------------

  Hadith? getCachedHadith(String slug, int number) =>
      cache.getHadith(slug, number);

  List<Hadith> getCachedHadiths({String? slug}) =>
      cache.getCachedHadiths(slug: slug);

  List<Hadith> searchCachedHadiths(
    Iterable<String> keywords, {
    String? slug,
    int limit = 30,
  }) =>
      cache.searchCachedHadiths(keywords, slug: slug, limit: limit);

  int get cachedHadithCount => cache.cachedHadithCount;

  /// Cache tidak boleh membuat request yang sukses menjadi gagal.
  Future<void> _tryCache(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Data tetap tampil meski penyimpanan lokal gagal.
    }
  }
}
