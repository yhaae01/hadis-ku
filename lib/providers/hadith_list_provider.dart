import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../services/hadith_api_service.dart';

/// Mengelola daftar hadis satu kitab dengan pagination/lazy loading.
class HadithListProvider extends SafeChangeNotifier {
  HadithListProvider({required this.book, HadithApiService? service})
      : _service = service ?? HadithApiService();

  final HadithBook book;
  final HadithApiService _service;

  final List<Hadith> _items = [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _loadMoreError;
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalItems = 0;

  List<Hadith> get items => _items;
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
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
      final page = await _service.fetchHadiths(
        book.slug,
        page: 1,
        limit: ApiConfig.pageSize,
      );

      _items
        ..clear()
        ..addAll(page.items);
      _currentPage = page.pagination.currentPage;
      _totalPages = page.pagination.totalPages;
      _totalItems = page.pagination.totalItems;
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
      final page = await _service.fetchHadiths(
        book.slug,
        page: _currentPage + 1,
        limit: ApiConfig.pageSize,
      );

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
