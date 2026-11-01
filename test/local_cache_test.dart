import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:hadis_ku/models/hadith.dart';
import 'package:hadis_ku/models/hadith_book.dart';
import 'package:hadis_ku/services/local_cache_service.dart';

void main() {
  late Directory tempDir;
  late LocalCacheService cache;

  Hadith hadith(int number, {String slug = 'bukhari', String text = 'Hadis'}) {
    return Hadith(
      number: number,
      arabic: 'نص',
      translation: text,
      bookName: 'Bukhari',
      bookSlug: slug,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hadis_ku_cache_test');
    cache = LocalCacheService();
    await cache.init(dir: tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('kitab yang disimpan tetap terbaca offline', () async {
    await cache.saveBooks([
      const HadithBook(name: 'Bukhari', slug: 'bukhari', total: 6638),
      const HadithBook(name: 'Muslim', slug: 'muslim', total: 4930),
    ]);

    final books = cache.getBooks();

    expect(books, hasLength(2));
    expect(books.first.name, 'Bukhari');
    expect(cache.getBook('muslim')?.total, 4930);
  });

  test('halaman daftar hadis disusun ulang dari cache', () async {
    await cache.saveBook(
      const HadithBook(name: 'Bukhari', slug: 'bukhari', total: 6638),
    );
    await cache.saveHadiths([
      for (var number = 1; number <= 45; number++) hadith(number),
    ]);

    final firstPage = cache.getHadithsPage('bukhari', page: 1, limit: 20);
    final secondPage = cache.getHadithsPage('bukhari', page: 2, limit: 20);
    final lastPage = cache.getHadithsPage('bukhari', page: 3, limit: 20);
    final beyondCache = cache.getHadithsPage('bukhari', page: 4, limit: 20);

    expect(firstPage!.items.map((h) => h.number), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
    expect(secondPage!.pagination.currentPage, 2);
    expect(secondPage.items.first.number, 21);
    expect(lastPage!.items.length, 5);
    expect(lastPage.pagination.totalPages, 3);
    expect(beyondCache, isNull);
    expect(cache.getHadithsPage('bukhari', page: 1, limit: 20)!.pagination.totalItems, 45);
  });

  test('pencarian offline menemukan kata kunci pada data tersimpan', () async {
    await cache.saveHadiths([
      hadith(1, text: 'Setiap amal tergantung niatnya'),
      hadith(2, text: 'Halal itu jelas dan haram itu jelas'),
      hadith(3, slug: 'muslim', text: 'Mari kita ringankan urusan shalat'),
    ]);

    expect(
      cache.searchCachedHadiths(['niat']).single.number,
      1,
    );
    expect(
      cache.searchCachedHadiths(['haram']).single.bookSlug,
      'bukhari',
    );
    expect(
      cache.searchCachedHadiths(['sholat', 'shalat'], slug: 'muslim')
          .single
          .number,
      3,
    );
    expect(
      cache.searchCachedHadiths(['niat'], slug: 'muslim'),
      isEmpty,
    );
  });

  test('kunci cache menggabungkan slug kitab dan nomor hadis', () async {
    expect(LocalCacheService.hadithKey('bukhari', 1), 'bukhari_1');

    await cache.saveHadith(hadith(1));
    await cache.saveHadith(hadith(1, slug: 'muslim'));

    expect(cache.getHadith('bukhari', 1)?.translation, 'Hadis');
    expect(cache.cachedHadithCount, 2);
  });
}
