import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/books_provider.dart';
import 'services/hadith_repository.dart';
import 'services/local_cache_service.dart';
import 'views/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi service penyimpanan lokal & repositori
  final cache = LocalCacheService();
  final repository = HadithRepository(cache: cache);

  // Jalankan aplikasi langsung dengan SplashScreen agar proses asinkron
  // berjalan transparan di background dengan umpan balik visual yang informatif.
  runApp(HadisKuApp(cache: cache, repository: repository));
}

/// Root widget aplikasi HadisKu dengan tema Material 3 Islami dan
/// inisialisasi MultiProvider.
class HadisKuApp extends StatelessWidget {
  const HadisKuApp({
    super.key,
    required this.cache,
    required this.repository,
  });

  final LocalCacheService cache;
  final HadithRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalCacheService>.value(value: cache),
        Provider<HadithRepository>.value(value: repository),
        ChangeNotifierProvider<BooksProvider>(
          // Provider dibuat di sini, proses load dijalankan oleh SplashView
          // pada tahapan sinkronisasi data yang sesuai.
          create: (_) => BooksProvider(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'HadisKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: SplashView(cache: cache),
      ),
    );
  }
}
