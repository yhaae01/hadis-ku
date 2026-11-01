import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith_book.dart';
import '../services/hadith_repository.dart';

/// Memuat daftar kitab hadis dari internet dengan fallback cache offline.
class BooksProvider extends SafeChangeNotifier {
  BooksProvider({required this.repository});

  final HadithRepository repository;

  List<HadithBook> _books = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _isFromCache = false;
  String? _error;

  List<HadithBook> get books => _books;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get isFromCache => _isFromCache;
  String? get error => _error;

  /// Jumlah hadis yang sudah tersimpan di perangkat untuk mode offline.
  int get cachedHadiths => repository.cachedHadithCount;

  int get totalHadiths =>
      _books.fold<int>(0, (total, book) => total + book.total);

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !force) return;

    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      final result = await repository.fetchBooks();
      _books = result.data;
      _isFromCache = result.fromCache;
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
