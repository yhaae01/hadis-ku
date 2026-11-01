import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/books_provider.dart';
import '../services/local_cache_service.dart';
import 'home_view.dart';

/// Halaman splash/loading awal dengan indikator estetik dan teks status
/// dinamis yang menginformasikan proses inisialisasi secara real-time.
class SplashView extends StatefulWidget {
  const SplashView({
    super.key,
    required this.cache,
    this.nextScreen,
  });

  final LocalCacheService cache;

  /// Layar tujuan setelah inisialisasi selesai (default: [HomeView]).
  final Widget? nextScreen;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String _statusTitle = 'Memulai HadisKu...';
  String _statusSubtitle = 'Menyiapkan aplikasi untuk Anda';
  double _progressValue = 0.1;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  void _updateStatus(String title, String subtitle, double progress) {
    if (!mounted) return;
    setState(() {
      _statusTitle = title;
      _statusSubtitle = subtitle;
      _progressValue = progress;
      _hasError = false;
      _errorMessage = null;
    });
  }

  Future<void> _startInitialization() async {
    try {
      // ----------------------------------------------------------------------
      // Tahap 1: Inisialisasi Database Offline (Hive)
      // ----------------------------------------------------------------------
      _updateStatus(
        'Memuat database offline...',
        'Menyiapkan penyimpanan lokal Hive di perangkat',
        0.25,
      );

      await widget.cache.init();

      // Berikan jeda halus agar transisi status terbaca nyaman oleh pengguna.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      // ----------------------------------------------------------------------
      // Tahap 2: Sinkronisasi Data Kitab Hadis
      // ----------------------------------------------------------------------
      final hasLocalBooks = widget.cache.getBooks().isNotEmpty;
      _updateStatus(
        hasLocalBooks
            ? 'Menyinkronkan data kitab...'
            : 'Menghubungkan ke server hadis...',
        hasLocalBooks
            ? 'Memeriksa pembaruan data dan cache lokal'
            : 'Mengunduh daftar 9 kitab hadis utama',
        0.55,
      );

      final booksProvider = context.read<BooksProvider>();
      await booksProvider.load();
      if (!mounted) return;

      // Jika data kitab kosong dan terjadi error (offline pertama kali)
      if (booksProvider.books.isEmpty && booksProvider.error != null) {
        setState(() {
          _hasError = true;
          _errorMessage =
              booksProvider.error ?? 'Gagal memuat data dari server.';
        });
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      // ----------------------------------------------------------------------
      // Tahap 3: Menyiapkan Kategori Pilihan
      // ----------------------------------------------------------------------
      _updateStatus(
        'Menyiapkan kategori pilihan...',
        'Menata topik tematik dan indeks hadis',
        0.85,
      );

      // Sedikit jeda untuk memastikan thread UI tetap responsif
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // ----------------------------------------------------------------------
      // Tahap 4: Finalisasi & Transisi ke Layar Utama
      // ----------------------------------------------------------------------
      _updateStatus(
        'Membuka beranda HadisKu...',
        'Pustaka hadis siap digunakan',
        1.0,
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      _navigateToHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kendala saat inisialisasi: $e';
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return widget.nextScreen ?? const HomeView();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF062E1D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF042416),
                Color(0xFF0B5D3B),
                Color(0xFF063320),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ----------------------------------------------------------
                  // Logo & Identitas Aplikasi
                  // ----------------------------------------------------------
                  _AppBrandEmblem(),
                  const SizedBox(height: 24),
                  Text(
                    'HadisKu',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pustaka Hadis Digital & Terjemahan',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFD8EFE2).withValues(alpha: 0.85),
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ----------------------------------------------------------
                  // Loading Indicator atau Kartu Error
                  // ----------------------------------------------------------
                  if (_hasError)
                    _ErrorRetryCard(
                      errorMessage: _errorMessage ?? 'Gagal memuat data awal.',
                      onRetry: _startInitialization,
                    )
                  else
                    _LoadingStatusIndicator(
                      title: _statusTitle,
                      subtitle: _statusSubtitle,
                      progress: _progressValue,
                    ),

                  const Spacer(flex: 1),

                  // ----------------------------------------------------------
                  // Footer Versi / Hak Cipta
                  // ----------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Pustaka 9 Kitab Hadis Nabawi',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo aplikasi dengan bingkai elegan bernuansa hijau-emas Islami.
class _AppBrandEmblem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0E4C31),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.65),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.15),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/icon/splash-logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              // Fallback ikon bila asset belum siap / mode test
              return const Icon(
                Icons.auto_stories_rounded,
                size: 52,
                color: AppTheme.gold,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Indikator loading melingkar dengan animasi halus dan teks dinamis.
class _LoadingStatusIndicator extends StatelessWidget {
  const _LoadingStatusIndicator({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lingkaran loading bergaya Islami: cincin emas dengan latar lembut
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Teks status judul dengan animasi transisi yang mulus
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            title,
            key: ValueKey<String>(title),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Keterangan detail proses di bawah teks utama
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            subtitle,
            key: ValueKey<String>(subtitle),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFD8EFE2).withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Indikator linear tipis sebagai penanda progress tahapan
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 3.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu penanganan error jika sinkronisasi awal gagal total (misal offline
/// pada pembukaan pertama kali sebelum ada cache lokal).
class _ErrorRetryCard extends StatelessWidget {
  const _ErrorRetryCard({
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF073A25).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.gold,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'Koneksi Internet Diperlukan',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$errorMessage\nPastikan koneksi internet aktif untuk mengunduh data awal.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFD8EFE2).withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: const Color(0xFF1D2F23),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias agar pengembang dapat menggunakan nama [SplashScreen] maupun [SplashView].
typedef SplashScreen = SplashView;

