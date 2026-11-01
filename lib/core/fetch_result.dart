/// Hasil pembacaan data lengkap dengan asal-usulnya.
///
/// [fromCache] true bila data dilayani dari penyimpanan lokal karena
/// permintaan ke jaringan gagal (mode offline).
class FetchResult<T> {
  const FetchResult(this.data, {this.fromCache = false});

  final T data;
  final bool fromCache;
}
