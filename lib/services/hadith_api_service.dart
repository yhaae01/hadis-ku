import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../core/text_normalizer.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../models/hadith_page.dart';

/// Lapisan akses data ke https://github.com/renomureza/hadis-api-id.
class HadithApiService {
  HadithApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// `GET /hadith` — daftar seluruh kitab.
  Future<List<HadithBook>> fetchBooks() async {
    final data = await _get('/hadith');
    if (data is! List) {
      throw const ApiException('Format data kitab tidak dikenali.');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(HadithBook.fromJson)
        .toList(growable: false);
  }

  /// `GET /hadith/{slug}?page=&limit=`
  Future<HadithPage> fetchHadiths(
    String slug, {
    int page = 1,
    int limit = ApiConfig.pageSize,
  }) async {
    final data = await _get(
      '/hadith/${Uri.encodeComponent(slug)}',
      query: {'page': '$page', 'limit': '$limit'},
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Format data hadis tidak dikenali.');
    }

    return HadithPage.fromJson(data);
  }

  /// `GET /hadith/{slug}/{number}`
  Future<Hadith> fetchHadith(String slug, int number) async {
    final data = await _get(
      '/hadith/${Uri.encodeComponent(slug)}/$number',
      notFoundMessage:
          'Hadis nomor $number tidak ditemukan pada kitab yang dipilih.',
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Format data hadis tidak dikenali.');
    }

    return Hadith.fromJson(data);
  }

  /// Pencarian kata kunci dilakukan di sisi aplikasi karena API tidak
  /// menyediakan endpoint pencarian. Data dipindai per halaman dan
  /// pemindaian berhenti setelah [ApiConfig.maxSearchResults] hasil ditemukan
  /// atau seluruh kitab selesai dipindai.
  Future<List<Hadith>> searchHadiths({
    required String slug,
    required String keyword,
    void Function(int scannedPage, int totalPages)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final needle = normalizeForSearch(keyword);
    final results = <Hadith>[];

    var page = 1;
    var totalPages = 1;

    while (page <= totalPages) {
      if (isCancelled?.call() ?? false) break;

      final result = await fetchHadiths(
        slug,
        page: page,
        limit: ApiConfig.searchPageSize,
      );
      totalPages = result.pagination.totalPages;

      for (final hadith in result.items) {
        final matches = normalizeForSearch(hadith.arabic).contains(needle) ||
            normalizeForSearch(hadith.translation).contains(needle);
        if (matches) {
          results.add(hadith);
          if (results.length >= ApiConfig.maxSearchResults) break;
        }
      }

      onProgress?.call(page, totalPages);

      if (results.length >= ApiConfig.maxSearchResults) break;
      page++;
    }

    return results;
  }

  Future<dynamic> _get(
    String path, {
    Map<String, String>? query,
    String? notFoundMessage,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);

    http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException(
        'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (_) {
      throw const ApiException(
        'Terjadi kesalahan jaringan. Silakan coba lagi.',
      );
    }

    if (response.statusCode != 200) {
      throw _errorFor(response, notFoundMessage: notFoundMessage);
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('Respons dari server tidak dapat dibaca.');
    }
  }

  ApiException _errorFor(http.Response response, {String? notFoundMessage}) {
    if (response.statusCode == 404) {
      return ApiException(
        notFoundMessage ?? 'Data yang diminta tidak ditemukan.',
      );
    }
    if (response.statusCode >= 500) {
      return const ApiException(
        'Server sedang bermasalah. Coba beberapa saat lagi.',
      );
    }
    return ApiException('Permintaan gagal (kode ${response.statusCode}).');
  }
}
