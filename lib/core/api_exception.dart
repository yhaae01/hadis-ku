/// Exception dengan pesan yang aman ditampilkan langsung ke pengguna.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
