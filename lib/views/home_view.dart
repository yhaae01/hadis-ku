import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../core/topic_catalog.dart';
import '../providers/books_provider.dart';
import '../widgets/kitab_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/status_message.dart';
import '../widgets/topic_card.dart';
import 'hadith_list_view.dart';
import 'search_view.dart';
import 'topic_detail_view.dart';
import 'topics_view.dart';

/// Halaman utama: sapaan, akses pencarian, dan daftar kitab hadis.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BooksProvider>();
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            _HomeHeader(
              bookCount: provider.books.length,
              totalHadiths: provider.totalHadiths,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.green,
                onRefresh: () =>
                    context.read<BooksProvider>().load(force: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 28),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (provider.isFromCache &&
                                    provider.books.isNotEmpty) ...[
                                  _OfflineBanner(
                                    cachedHadiths: provider.cachedHadiths,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                _SearchEntry(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const SearchView(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Row(
                                  children: [
                                    Text(
                                      'Jelajahi Topik',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const TopicsView(),
                                        ),
                                      ),
                                      child: const Text('Lihat semua'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hadis rujukan tiap topik disimpan otomatis '
                                  'ke perangkat untuk mode offline.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 122,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: hadithTopics.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final topic = hadithTopics[index];
                                      return TopicCard(
                                        topic: topic,
                                        onTap: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                TopicDetailView(topic: topic),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Text(
                                      'Kitab Hadis',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const Spacer(),
                                    if (provider.books.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${provider.books.length} kitab',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppTheme.deepGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pilih kitab untuk mulai membaca hadis.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                if (provider.isLoading &&
                                    provider.books.isEmpty)
                                  const LoadingState(
                                    message: 'Memuat daftar kitab...',
                                  )
                                else if (provider.error != null &&
                                    provider.books.isEmpty)
                                  StatusMessage(
                                    icon: Icons.cloud_off_rounded,
                                    title: 'Gagal memuat kitab',
                                    message: provider.error!,
                                    action: FilledButton.tonalIcon(
                                      onPressed: () => context
                                          .read<BooksProvider>()
                                          .load(force: true),
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Coba lagi'),
                                    ),
                                  )
                                else if (provider.books.isEmpty)
                                  const StatusMessage(
                                    icon: Icons.menu_book_outlined,
                                    title: 'Belum ada kitab',
                                    message:
                                        'Daftar kitab tidak tersedia saat ini.',
                                  )
                                else
                                  for (final book in provider.books)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: KitabCard(
                                        book: book,
                                        onTap: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                HadithListView(book: book),
                                          ),
                                        ),
                                      ),
                                    ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sumber data: Hadis API Indonesia',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.bookCount, required this.totalHadiths});

  final int bookCount;
  final int totalHadiths;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.deepGreen, AppTheme.green, Color(0xFF117A51)],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -30,
              child: _DecorCircle(size: 150, color: Color(0x14FFFFFF)),
            ),
            const Positioned(
              bottom: -60,
              left: -40,
              child: _DecorCircle(size: 170, color: Color(0x0FFFFFFF)),
            ),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0x1FFFFFFF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0x33FFFFFF),
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HadisKu',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Hadis Nabawi • Terjemahan Indonesia',
                                    style: TextStyle(
                                      color: Color(0xCCFFFFFF),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'الْحَدِيثُ النَّبَوِيُّ',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Color(0xFFFFE7A3),
                            fontSize: 20,
                            fontFamilyFallback: [
                              'Noto Naskh Arabic',
                              'Scheherazade New',
                              'Amiri',
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Baca dan telusuri hadis dari kitab-kitab terpercaya.',
                          style: TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        if (bookCount > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatChip(
                                icon: Icons.menu_book_outlined,
                                label: '$bookCount kitab',
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                icon: Icons.format_list_numbered_rounded,
                                label: '${formatNumber(totalHadiths)} hadis',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.cachedHadiths});

  final int cachedHadiths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cachedHadiths > 0
                  ? 'Mode offline: menampilkan data dari penyimpanan perangkat '
                      '($cachedHadiths hadis tersimpan).'
                  : 'Mode offline: menampilkan data terakhir dari penyimpanan '
                      'perangkat.',
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

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xCCFFFFFF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cari Hadis', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Kata kunci atau nomor hadis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
