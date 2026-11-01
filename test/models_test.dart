import 'package:flutter_test/flutter_test.dart';
import 'package:hadis_ku/core/formatters.dart';
import 'package:hadis_ku/core/text_normalizer.dart';
import 'package:hadis_ku/models/hadith.dart';
import 'package:hadis_ku/models/hadith_page.dart';

void main() {
  group('formatNumber', () {
    test('memakai pemisah ribuan Indonesia', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(999), '999');
      expect(formatNumber(1000), '1.000');
      expect(formatNumber(6638), '6.638');
      expect(formatNumber(38102), '38.102');
    });
  });

  test('Hadith.fromJson membaca field terjemahan "id"', () {
    final hadith = Hadith.fromJson(
      {
        'number': 1,
        'arab': 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
        'id': 'Semua perbuatan tergantung niatnya',
        'name': 'Bukhari',
        'slug': 'bukhari',
      },
    );

    expect(hadith.number, 1);
    expect(hadith.arabic, startsWith('إِنَّمَا'));
    expect(hadith.translation, 'Semua perbuatan tergantung niatnya');
    expect(hadith.bookName, 'Bukhari');
    expect(hadith.bookSlug, 'bukhari');
  });

  test('HadithPage.fromJson membaca pagination dan mewarisi kitab', () {
    final page = HadithPage.fromJson({
      'name': 'Bukhari',
      'slug': 'bukhari',
      'total': 6638,
      'pagination': {
        'totalItems': 6638,
        'currentPage': 2,
        'pageSize': 20,
        'totalPages': 332,
      },
      'items': [
        {'number': 21, 'arab': 'نص', 'id': 'terjemahan'},
      ],
    });

    expect(page.book.name, 'Bukhari');
    expect(page.pagination.currentPage, 2);
    expect(page.pagination.hasNextPage, isTrue);
    expect(page.items.single.bookSlug, 'bukhari');
    expect(page.items.single.bookName, 'Bukhari');
  });

  test('normalizeForSearch mengabaikan harakat dan varian huruf Arab', () {
    expect(
      normalizeForSearch('الْأَعْمَالُ'),
      normalizeForSearch('الاعمال'),
    );
    expect(normalizeForSearch('Sabar'), 'sabar');
  });
}
