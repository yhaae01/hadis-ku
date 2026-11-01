import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith.dart';
import '../services/hadith_api_service.dart';

/// Menangani pencarian nomor hadis (langsung ke endpoint detail) dan
/// pencarian kata kunci (memindai endpoint daftar per halaman).
class HadithSearchProvider extends SafeChangeNotifier {
  HadithSearchProvider({HadithApiService? service})
      : _service = service ?? HadithApiService();

  final HadithApiService _service;

  List<Hadith> _results = const [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _cancelRequested = false;
  String? _error;
  String? _info;
  int _scannedPage = 0;
  int _totalPages = 0;

  List<Hadith> get results => _results;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String? get error => _error;
  String? get info => _info;
  int get scannedPage => _scannedPage;
  int get totalPages => _totalPages;

  Future<void> search({
    required String keyword,
    required String slug,
  }) async {
    if (_isSearching) return;

    final query = keyword.trim();
    if (query.isEmpty) {
      _error = 'Masukkan kata kunci atau nomor hadis terlebih dahulu.';
      _info = null;
      safeNotifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = false;
    _cancelRequested = false;
    _error = null;
    _info = null;
    _results = const [];
    _scannedPage = 0;
    _totalPages = 0;
    safeNotifyListeners();

    try {
      final number = int.tryParse(query);

      if (number != null) {
        final hadith = await _service.fetchHadith(slug, number);
        if (_cancelRequested) return;

        _results = [hadith];
        _scannedPage = 1;
        _totalPages = 1;
      } else {
        _results = await _service.searchHadiths(
          slug: slug,
          keyword: query,
          isCancelled: () => _cancelRequested || isDisposed,
          onProgress: (page, totalPages) {
            _scannedPage = page;
            _totalPages = totalPages;
            safeNotifyListeners();
          },
        );

        if (_cancelRequested) return;
      }

      _hasSearched = true;
    } on ApiException catch (e) {
      if (!_cancelRequested) _error = e.message;
    } catch (_) {
      if (!_cancelRequested) {
        _error = 'Terjadi kesalahan saat mencari. Silakan coba lagi.';
      }
    } finally {
      if (_cancelRequested) {
        _hasSearched = false;
        _info = 'Pencarian dihentikan.';
      }
      _isSearching = false;
      safeNotifyListeners();
    }
  }

  void cancel() {
    if (!_isSearching) return;
    _cancelRequested = true;
    safeNotifyListeners();
  }

  @override
  void dispose() {
    _cancelRequested = true;
    super.dispose();
  }
}
