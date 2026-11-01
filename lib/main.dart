import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/books_provider.dart';
import 'services/hadith_repository.dart';
import 'services/local_cache_service.dart';
import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Buka box Hive sebelum aplikasi berjalan agar data offline langsung siap.
  final cache = LocalCacheService();
  await cache.init();

  final repository = HadithRepository(cache: cache);

  runApp(HadisKuApp(repository: repository));
}

class HadisKuApp extends StatelessWidget {
  const HadisKuApp({super.key, required this.repository});

  final HadithRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HadithRepository>.value(value: repository),
        ChangeNotifierProvider<BooksProvider>(
          create: (_) => BooksProvider(repository: repository)..load(),
        ),
      ],
      child: MaterialApp(
        title: 'HadisKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeView(),
      ),
    );
  }
}
