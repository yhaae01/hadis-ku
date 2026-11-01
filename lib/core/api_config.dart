/// Konfigurasi akses ke REST API hadis.
class ApiConfig {
  ApiConfig._();

  /// Base URL dari https://github.com/renomureza/hadis-api-id
  static const String baseUrl = 'https://hadis-api-id.vercel.app';

  static const Duration timeout = Duration(seconds: 30);

  /// Jumlah hadis per halaman pada daftar hadis.
  static const int pageSize = 20;

  /// Jumlah hadis per permintaan saat memindai data untuk pencarian.
  static const int searchPageSize = 500;

  /// Batas hasil pencarian agar pemindaian tidak berlangsung terlalu lama.
  static const int maxSearchResults = 20;
}
