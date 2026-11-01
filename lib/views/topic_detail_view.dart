import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../models/hadith_topic.dart';
import '../providers/books_provider.dart';
import '../providers/topic_provider.dart';
import '../services/hadith_repository.dart';
import '../widgets/hadith_tile.dart';
import '../widgets/loading_state.dart';
import '../widgets/status_message.dart';
import 'hadith_detail_view.dart';
import 'search_view.dart';

/// Menampilkan hadis yang relevan dengan satu topik pilihan.
class TopicDetailView extends StatelessWidget {
  const TopicDetailView({super.key, required this.topic});

  final HadithTopic topic;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TopicProvider>(
      create: (context) => TopicProvider(
        topic: topic,
        repository: context.read<HadithRepository>(),
      )..load(),
      child: _TopicDetailBody(topic: topic),
    );
  }
}

class _TopicDetailBody extends StatelessWidget {
  const _TopicDetailBody({required this.topic});

  final HadithTopic topic;

  HadithBook _bookFor(List<HadithBook> books, Hadith hadith) {
    for (final book in books) {
      if (book.slug == hadith.bookSlug) return book;
    }
    return HadithBook(
      name: hadith.bookName.isEmpty ? 'Hadis' : hadith.bookName,
      slug: hadith.bookSlug,
      total: 0,
    );
  }

  void _openDetail(BuildContext context, Hadith hadith) {
    final books = context.read<BooksProvider>().books;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HadithDetailView(
          book: _bookFor(books, hadith),
          number: hadith.number,
        ),
      ),
    );
  }

  void _openKeywordSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchView(initialKeyword: topic.keywords.first),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TopicProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator(
            color: AppTheme.green,
            onRefresh: () => context.read<TopicProvider>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _TopicHeader(topic: topic, count: provider.hadiths.length),
                const SizedBox(height: 16),
                if (provider.isLoading && provider.hadiths.isEmpty)
                  const LoadingState(message: 'Memuat hadis topik...')
                else if (provider.error != null && provider.hadiths.isEmpty)
                  StatusMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'Hadis topik belum tersedia',
                    message: provider.error!,
                    action: FilledButton.tonalIcon(
                      onPressed: () => context.read<TopicProvider>().load(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Coba lagi'),
                    ),
                  )
                else if (provider.hadiths.isEmpty)
                  const StatusMessage(
                    icon: Icons.search_off_rounded,
                    title: 'Belum ada hadis',
                    message: 'Buka salah satu kitab terlebih dahulu agar hadis '
                        'topik ini tersimpan di perangkat.',
                  )
                else ...[
                  if (provider.incompleteMessage != null) ...[
                    _InfoBanner(message: provider.incompleteMessage!),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    children: [
                      Text('Hadis Topik', style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        '${provider.hadiths.length} hadis',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final hadith in provider.hadiths)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HadithTile(
                        hadith: hadith,
                        onTap: () => _openDetail(context, hadith),
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _openKeywordSearch(context),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Cari hadis topik lainnya'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic, required this.count});

  final HadithTopic topic;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.deepGreen, AppTheme.green, Color(0xFF117A51)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.arabicTitle,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Color(0xFFFFE7A3),
              fontSize: 22,
              fontFamilyFallback: [
                'Noto Naskh Arabic',
                'Scheherazade New',
                'Amiri',
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            topic.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            topic.description,
            style: const TextStyle(
              color: Color(0xD9FFFFFF),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count hadis tersimpan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
