import 'package:flutter/foundation.dart';

/// ChangeNotifier yang aman dipakai bersama proses async panjang
/// (misalnya request HTTP) meskipun provider sudah di-dispose.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @protected
  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
