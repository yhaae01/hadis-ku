import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../services/hadith_repository.dart';

/// Mengelola daftar hadis satu kitab dengan pagination/lazy loading.
///
/// Data yang berhasil dimuat otomatis tersimpan di Hive, sehingga halaman
/// yang pernah dibuka tetap bisa dibaca saat perangkat offline.
class HadithListProvider extends SafeChangeNotifier {
  HadithListProvider({required this.book, required this.repository});

  final HadithBook book;
  final HadithRepository repository;

  final List<Hadith> _items = [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _isFromCache = false;
  String? _error;
  String? _loadMoreError;
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalItems = 0;

  List<Hadith> get items => _items;
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;

  /// True bila halaman yang ditampilkan berasal dari cache offline.
  bool get isFromCache => _isFromCache;
  String? get error => _error;
  String? get loadMoreError => _loadMoreError;
  bool get hasMore => _currentPage < _totalPages;
  int get totalItems => _totalItems == 0 ? book.total : _totalItems;

  Future<void> loadInitial() async {
    if (_isInitialLoading) return;

    _isInitialLoading = true;
    _error = null;
    _loadMoreError = null;
    safeNotifyListeners();

    try {
      final result = await repository.fetchHadiths(
        book.slug,
        page: 1,
        limit: ApiConfig.pageSize,
      );
      final page = result.data;

      _items
        ..clear()
        ..addAll(page.items);
      _currentPage = page.pagination.currentPage;
      _totalPages = page.pagination.totalPages;
      _totalItems = page.pagination.totalItems;
      _isFromCache = result.fromCache;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat hadis. Silakan coba lagi.';
    } finally {
      _isInitialLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isInitialLoading || _isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    _loadMoreError = null;
    safeNotifyListeners();

    try {
      final result = await repository.fetchHadiths(
        book.slug,
        page: _currentPage + 1,
        limit: ApiConfig.pageSize,
      );
      final page = result.data;

      _items.addAll(page.items);
      _currentPage = page.pagination.currentPage;
      _totalPages = page.pagination.totalPages;
      _totalItems = page.pagination.totalItems;
    } on ApiException catch (e) {
      _loadMoreError = e.message;
    } catch (_) {
      _loadMoreError = 'Gagal memuat hadis berikutnya.';
    } finally {
      _isLoadingMore = false;
      safeNotifyListeners();
    }
  }

  Future<void> refresh() => loadInitial();
}
