import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../services/hadith_repository.dart';

/// Memuat detail satu hadis dari internet; bila gagal, mengambil dari cache.
class HadithDetailProvider extends SafeChangeNotifier {
  HadithDetailProvider({
    required this.book,
    required this.number,
    required this.repository,
  });

  final HadithBook book;
  final int number;
  final HadithRepository repository;

  Hadith? _hadith;
  bool _isLoading = false;
  bool _isFromCache = false;
  String? _error;

  Hadith? get hadith => _hadith;
  bool get isLoading => _isLoading;
  bool get isFromCache => _isFromCache;
  String? get error => _error;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      final result = await repository.fetchHadith(book.slug, number);
      _hadith = result.data;
      _isFromCache = result.fromCache;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat detail hadis. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }
}
