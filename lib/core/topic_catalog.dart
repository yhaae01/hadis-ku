import '../models/hadith_topic.dart';

/// Katalog topik beserta hadis rujukan yang sudah diperiksa dari data API.
const List<HadithTopic> hadithTopics = [
  HadithTopic(
    id: 'niat',
    title: 'Niat',
    arabicTitle: 'النية',
    description: 'Memulai setiap amal dengan niat yang benar dan ikhlas.',
    keywords: ['niat', 'niatnya', 'نية', 'النية'],
    references: [
      HadithReference(slug: 'bukhari', number: 1),
    ],
  ),
  HadithTopic(
    id: 'iman',
    title: 'Iman',
    arabicTitle: 'الإيمان',
    description: 'Rukun, hakikat, dan buah dari keimanan kepada Allah.',
    keywords: ['iman', 'beriman', 'keimanan', 'ايمان', 'الإيمان'],
    references: [
      HadithReference(slug: 'bukhari', number: 7),
      HadithReference(slug: 'muslim', number: 19),
    ],
  ),
  HadithTopic(
    id: 'shalat',
    title: 'Shalat',
    arabicTitle: 'الصلاة',
    description: 'Kewajiban, keutamaan, dan cahaya shalat lima waktu.',
    keywords: ['shalat', 'salat', 'sholat', 'صلاة', 'الصلاة'],
    references: [
      HadithReference(slug: 'bukhari', number: 497),
      HadithReference(slug: 'muslim', number: 12),
    ],
  ),
  HadithTopic(
    id: 'akhlak',
    title: 'Akhlak',
    arabicTitle: 'الأخلاق',
    description: 'Akhlak mulia dan budi pekerti teladan Rasulullah.',
    keywords: ['akhlak', 'budi pekerti', 'perangai', 'أخلاق', 'الأخلاق'],
    references: [
      HadithReference(slug: 'muslim', number: 3941),
      HadithReference(slug: 'bukhari', number: 3972),
    ],
  ),
  HadithTopic(
    id: 'makanan-minuman',
    title: 'Makanan & Minuman',
    arabicTitle: 'الطعام والشراب',
    description: 'Adab makan, berbagi rezeki, dan ketentuan minuman.',
    keywords: ['makanan', 'minuman', 'makan', 'minum', 'طعام', 'شراب'],
    references: [
      HadithReference(slug: 'muslim', number: 3556),
      HadithReference(slug: 'bukhari', number: 235),
    ],
  ),
  HadithTopic(
    id: 'sabar',
    title: 'Sabar',
    arabicTitle: 'الصبر',
    description: 'Keutamaan menahan diri dan bersabar atas ujian.',
    keywords: ['sabar', 'kesabaran', 'bersabar', 'صبر', 'الصبر'],
    references: [
      HadithReference(slug: 'bukhari', number: 1376),
      HadithReference(slug: 'muslim', number: 1452),
    ],
  ),
  HadithTopic(
    id: 'ilmu',
    title: 'Ilmu',
    arabicTitle: 'العلم',
    description: 'Keutamaan menuntut ilmu dan mengamalkannya.',
    keywords: ['ilmu', 'menuntut ilmu', 'mengajarkan', 'علم', 'العلم'],
    references: [
      HadithReference(slug: 'bukhari', number: 77),
      HadithReference(slug: 'tirmidzi', number: 2504),
    ],
  ),
  HadithTopic(
    id: 'sedekah',
    title: 'Sedekah',
    arabicTitle: 'الصدقة',
    description: 'Keutamaan berbagi, berinfak, dan menolong sesama.',
    keywords: ['sedekah', 'shadaqah', 'infak', 'صدقة', 'الصدقة'],
    references: [
      HadithReference(slug: 'bukhari', number: 53),
      HadithReference(slug: 'bukhari', number: 4632),
    ],
  ),
];
