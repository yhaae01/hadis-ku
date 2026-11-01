import '../core/api_exception.dart';
import '../core/safe_change_notifier.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../services/hadith_api_service.dart';

/// Memuat detail satu hadis berdasarkan kitab dan nomornya.
class HadithDetailProvider extends SafeChangeNotifier {
  HadithDetailProvider({
    required this.book,
    required this.number,
    HadithApiService? service,
  }) : _service = service ?? HadithApiService();

  final HadithBook book;
  final int number;
  final HadithApiService _service;

  Hadith? _hadith;
  bool _isLoading = false;
  String? _error;

  Hadith? get hadith => _hadith;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      _hadith = await _service.fetchHadith(book.slug, number);
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
