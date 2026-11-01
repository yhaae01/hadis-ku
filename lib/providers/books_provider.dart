import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith_book.dart';
import '../services/hadith_api_service.dart';

/// Memuat daftar kitab hadis untuk halaman utama.
class BooksProvider extends SafeChangeNotifier {
  BooksProvider({HadithApiService? service})
      : _service = service ?? HadithApiService();

  final HadithApiService _service;

  List<HadithBook> _books = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<HadithBook> get books => _books;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  int get totalHadiths =>
      _books.fold<int>(0, (total, book) => total + book.total);

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !force) return;

    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      _books = await _service.fetchBooks();
      _hasLoaded = true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat daftar kitab. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }
}
