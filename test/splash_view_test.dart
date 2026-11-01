import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:hadis_ku/core/app_theme.dart';
import 'package:hadis_ku/models/hadith_book.dart';
import 'package:hadis_ku/providers/books_provider.dart';
import 'package:hadis_ku/services/hadith_repository.dart';
import 'package:hadis_ku/services/local_cache_service.dart';
import 'package:hadis_ku/views/splash_view.dart';

void main() {
  late Directory tempDir;
  late LocalCacheService cache;
  late HadithRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('splash_view_test');
    cache = LocalCacheService();
    await cache.init(dir: tempDir.path);
    // Simpan data buku contoh agar alur inisialisasi offline berhasil seketika
    await cache.saveBooks([
      const HadithBook(name: 'Bukhari', slug: 'bukhari', total: 6638),
      const HadithBook(name: 'Muslim', slug: 'muslim', total: 4930),
    ]);
    repository = HadithRepository(cache: cache);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('SplashView menampilkan logo, judul HadisKu, dan animasi loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LocalCacheService>.value(value: cache),
          Provider<HadithRepository>.value(value: repository),
          ChangeNotifierProvider<BooksProvider>(
            create: (_) => BooksProvider(repository: repository),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: SplashView(
            cache: cache,
            nextScreen: const Scaffold(body: Text('TargetScreen')),
          ),
        ),
      ),
    );

    // Verifikasi branding dan teks utama
    expect(find.text('HadisKu'), findsOneWidget);
    expect(find.text('Pustaka Hadis Digital & Terjemahan'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Berikan waktu animasi & async menyelesaikan seluruh tahapan
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Pastikan berhasil bertransisi ke layar target
    expect(find.text('TargetScreen'), findsOneWidget);
  });
}

