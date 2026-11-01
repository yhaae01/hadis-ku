import '../core/safe_change_notifier.dart';
import '../models/hadith.dart';
import '../models/hadith_topic.dart';
import '../services/hadith_repository.dart';

/// Menyusun hadis untuk satu topik dari dua sumber:
///
/// 1. **Cache lokal** — hadis rujukan topik yang sudah pernah dibuka dan
///    hasil pencarian kata kunci pada seluruh data tersimpan di perangkat.
///    Ditampilkan lebih dulu agar halaman topik tetap berguna saat offline.
/// 2. **Internet** — hadis rujukan topik yang belum tersimpan, diambil
///    berdasarkan kitab dan nomornya lalu disimpan ke Hive.
class TopicProvider extends SafeChangeNotifier {
  TopicProvider({required this.topic, required this.repository});

  final HadithTopic topic;
  final HadithRepository repository;

  List<Hadith> _hadiths = const [];
  bool _isLoading = false;
  int _missingRefs = 0;
  String? _error;
  String? _incompleteMessage;

  List<Hadith> get hadiths => _hadiths;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get incompleteMessage => _incompleteMessage;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _incompleteMessage = null;
    _missingRefs = 0;
    safeNotifyListeners();

    final collected = <String, Hadith>{};

    try {
      for (final ref in topic.references) {
        final cached = repository.getCachedHadith(ref.slug, ref.number);
        if (cached != null) collected[_key(cached)] = cached;
      }

      final localMatches = repository.searchCachedHadiths(
        topic.keywords,
        limit: 30,
      );
      for (final hadith in localMatches) {
        collected.putIfAbsent(_key(hadith), () => hadith);
      }

      _hadiths = _reorder(collected);

      if (_hadiths.isNotEmpty) {
        // Tampilkan dulu data offline, lalu lengkapi dari internet.
        _isLoading = false;
        safeNotifyListeners();
      }

      final missing = topic.references
          .where((ref) => !collected.containsKey(_refKey(ref)))
          .toList(growable: false);

      if (missing.isNotEmpty) {
        final fetched = await Future.wait(missing.map(_tryFetch));

        for (final hadith in fetched) {
          if (hadith == null) {
            _missingRefs++;
            continue;
          }
          collected[_key(hadith)] = hadith;
        }

        _hadiths = _reorder(collected);
      }

      if (_missingRefs > 0) {
        _incompleteMessage =
            'Sebagian hadis rujukan topik ini belum tersimpan offline. '
            'Sambungkan internet lalu muat ulang untuk melengkapinya.';
      } else if (_hadiths.isEmpty) {
        _error = 'Belum ada hadis untuk topik ini di perangkat. '
            'Sambungkan internet lalu muat ulang, atau buka kitab terkait terlebih dahulu.';
      }
    } catch (_) {
      if (_hadiths.isEmpty) {
        _error = 'Gagal memuat hadis topik. Silakan coba lagi.';
      }
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<Hadith?> _tryFetch(HadithReference ref) async {
    try {
      final result = await repository.fetchHadith(ref.slug, ref.number);
      return result.data;
    } catch (_) {
      return null;
    }
  }

  List<Hadith> _reorder(Map<String, Hadith> collected) {
    final ordered = <Hadith>[];
    final used = <String>{};

    for (final ref in topic.references) {
      final hadith = collected[_refKey(ref)];
      if (hadith != null && used.add(_key(hadith))) ordered.add(hadith);
    }

    for (final hadith in collected.values) {
      if (used.add(_key(hadith))) ordered.add(hadith);
    }

    return ordered;
  }

  String _key(Hadith hadith) => '${hadith.bookSlug}:${hadith.number}';

  String _refKey(HadithReference ref) => '${ref.slug}:${ref.number}';
}
